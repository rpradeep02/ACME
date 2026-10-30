module SalaryRecords
  class Create
    Result = Struct.new(:record, :errors, keyword_init: true) do
      def success?
        record.present? && errors.blank?
      end
    end

    def initialize(employee:, attributes:, actor:)
      @employee = employee
      @attributes = attributes
      @actor = actor
    end

    def call
      record = nil
      errors = nil

      Employee.transaction do
        @employee.lock!
        record = @employee.salary_records.build(@attributes)

        if record.valid?
          overlapping = @employee.salary_records
            .where("effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?)",
                   record.effective_to || Date.new(9999, 12, 31), record.effective_from)
            .to_a

          prior_open_period = overlapping.select do |existing|
            existing.effective_from < record.effective_from && existing.effective_to.nil?
          end
          other_conflicts = overlapping - prior_open_period

          if other_conflicts.any? || prior_open_period.length > 1
            record.errors.add(:effective_from, "overlaps an existing salary period")
            errors = record.errors.full_messages
            raise ActiveRecord::Rollback
          end

          prior_open_period.each do |existing|
            existing.update!(effective_to: record.effective_from - 1.day)
          end

          record.save!
          AuditEvent.create!(user: @actor, action: "salary_created", auditable: record,
                             metadata: { employee_code: @employee.employee_code, currency: record.currency,
                                         effective_from: record.effective_from.iso8601 })
        else
          errors = record.errors.full_messages
          raise ActiveRecord::Rollback
        end
      end

      Result.new(record: errors ? nil : record, errors: errors)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(record: nil, errors: e.record.errors.full_messages)
    end
  end
end
