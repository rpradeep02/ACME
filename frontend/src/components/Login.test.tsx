import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import Login from "./Login";

describe("Login", () => {
  it("submits credentials and reports API failures accessibly", async () => {
    const onLogin = vi.fn().mockRejectedValue(new Error("Invalid email or password"));
    render(<Login onLogin={onLogin} />);
    fireEvent.change(screen.getByLabelText("Password"), { target: { value: "bad-password" } });
    fireEvent.click(screen.getByRole("button", { name: "Sign in" }));
    await waitFor(() => expect(onLogin).toHaveBeenCalledWith("hr.manager@acme.example", "bad-password"));
    expect(await screen.findByRole("alert")).toHaveTextContent("Invalid email or password");
  });
});
