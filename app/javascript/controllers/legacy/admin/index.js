import { addRestartSericeEventer } from "./restart_service"

$(document).on("turbo:load", () => {
  addRestartSericeEventer()
})