export function confirmModalHandler(message, element, submitter) {
  const dialog = typeof document !== "undefined" ? document.getElementById("confirm-dialog") : null
  const controller = (dialog && typeof window !== "undefined")
    ? window.Stimulus?.getControllerForElementAndIdentifier(dialog, "confirm")
    : null

  if (controller) {
    const confirmText = submitter?.dataset?.turboConfirmOk || element?.dataset?.turboConfirmOk
    const cancelText = submitter?.dataset?.turboConfirmCancel || element?.dataset?.turboConfirmCancel

    return controller.ask({
      message,
      confirmText,
      cancelText
    })
  }

  // Fallback to browser native confirm if dialog or controller is not available
  const result = typeof window !== "undefined" && typeof window.confirm === "function"
    ? window.confirm(message)
    : true

  return Promise.resolve(result)
}
