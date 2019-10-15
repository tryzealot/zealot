// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require turbolinks
//= require rails-ujs
//= require jquery/dist/jquery.min
//= require bootstrap/dist/js/bootstrap.min
//= require admin-lte/dist/js/adminlte.min
//= require_tree .

var HOST = location.protocol + "//" + location.hostname + (location.port ? ':' + location.port : '') + '/';

document.addEventListener('turbolinks:load', function () {
  $(window).trigger('resize');
});

// auto switch dark mode
// $(document).ready(function () {
//   var isDarkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;
//   if (isDarkMode) {
//     $('body').removeClass('skin-black-light').addClass('skin-black');
//   }
// });