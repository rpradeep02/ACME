import { describe, expect, it } from "vitest";
import { formatDate, formatMoney, initials, localDateInputValue } from "./format";

describe("format helpers", () => {
  it("formats money using the requested currency", () => {
    expect(formatMoney(125000, "INR")).toContain("₹");
    expect(formatMoney(125000, "USD")).toContain("$");
  });

  it("falls back for unknown currency codes", () => {
    expect(formatMoney(1250, "XYZ")).toContain("XYZ");
  });

  it("formats dates deterministically in UTC", () => {
    expect(formatDate("2025-01-02")).toBe("02 Jan 2025");
    expect(formatDate(null)).toBe("—");
  });

  it("formats a date input using the local calendar date", () => {
    expect(localDateInputValue(new Date(2025, 0, 2))).toBe("2025-01-02");
  });

  it("builds initials from names", () => {
    expect(initials("Taylor", "Morgan")).toBe("TM");
  });
});
