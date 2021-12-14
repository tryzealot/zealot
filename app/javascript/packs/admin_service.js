import { restartService } from "javascripts/admin/service";

$(document).on("turbolinks:load", () => {
  var button = $("#restart-service-button");
  button.on("click", () => restartService(button));
});