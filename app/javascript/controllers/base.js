// var _Zealot = _Zealot || {}

// _Zealot.host = function () {
//   const HOST = location.protocol + "//" + location.hostname + (location.port ? ":" + location.port : "") + "/";
//   return HOST;
// }

// _Zealot.apperance = function () {
//   const HOST = location.protocol + "//" + location.hostname + (location.port ? ":" + location.port : "") + "/";
//   return HOST;
// }

const HOST = location.protocol + "//" + location.hostname + (location.port ? ":" + location.port : "") + "/";
window.HOST = HOST;

$(document).on("turbo:load", function () {
  // Fix tooltip toggle animation
  $("[data-toggle='tooltip']").tooltip();

  // Dark mode auto enable
  var isDarkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;
  if (SITE_APPEARANCE === "dark" || (SITE_APPEARANCE === "auto" && isDarkMode)) {
    $("body").addClass("dark-mode");
    $(".main-header").addClass("navbar-dark").removeClass("navbar-white");
    $(".main-sidebar").addClass("sidebar-dark-primary").removeClass("sidebar-light-primary");
  }
});
