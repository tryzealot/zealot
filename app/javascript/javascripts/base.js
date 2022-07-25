const HOST = location.protocol + "//" + location.hostname + (location.port ? ":" + location.port : "") + "/";
window.HOST = HOST;

$(document).on("turbolinks:load", function () {
  // fix body height for AdminLTE 2.4.0 and turbolinks 5
  $(window).trigger("resize");

  // enable tooltip global
  $("[data-toggle='tooltip']").tooltip();

  // // fix collapse with no response
  // $("[data-widget="collapse"]").each(function () {
  //   $(this).on("click", function () {
  //     var card = $(this).parents(".card");
  //     $(card).removeClass("collapsed-box");
  //     $(card).boxWidget("toggle");
  //   })
  // });

  // auto switch dark mode
  // var isDarkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;
  // console.log("darkmode: " + isDarkMode);

  // if (isDarkMode == true) {
    // $("body").addClass("dark-mode");
    // $(".main-header").addClass("navbar-dark").removeClass("navbar-white");
    // $(".main-sidebar").addClass("sidebar-dark-primary").removeClass("sidebar-light-primary");
  // }

  // $(document).Toasts('create', {
  //   title: 'Toast Title',
  //   body: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr.'
  // })
});
