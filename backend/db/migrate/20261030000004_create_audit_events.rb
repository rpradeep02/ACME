class CreateAuditEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false
      t.json :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :audit_events, %i[auditable_type auditable_id]
    add_index :audit_events, :created_at
  end
end
