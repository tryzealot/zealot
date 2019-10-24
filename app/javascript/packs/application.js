/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Import CSS
import 'bootstrap/dist/css/bootstrap'
import 'admin-lte/dist/css/AdminLTE'
import 'admin-lte/dist/css/skins/_all-skins'
import 'font-awesome/css/font-awesome'
import 'stylesheets/application'

// Import JS
import 'jquery'
import 'bootstrap'
import 'admin-lte'

require('@rails/ujs').start()
require('turbolinks').start()
require('javascripts/debug_files')
require('javascripts/releases')
require('javascripts/admin/system_info')

var HOST = location.protocol + "//" + location.hostname + (location.port ? ':' + location.port : '') + '/';


document.addEventListener('turbolinks:load', function () {
  // fix body height for AdminLTE 2.4.0 and turbolinks 5
  $(window).trigger('resize');

  $('[data-widget="collapse"]').each(function () {
    $(this).click(function () {
      $(this).parents('.box').boxWidget('toggle');
    })
  });

  // var collapse_buttons = document.querySelectorAll('[data-widget="collapse"]');
  // collapse_buttons.forEach(function (element) {
  //   element.addEventListener('click', function(event) {
  //     event.preventDefault();

  //     $(element).collapse()
  //   });
  // });
});

// auto switch dark mode
// $(document).ready(function () {
//   var isDarkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;
//   if (isDarkMode) {
//     $('body').removeClass('skin-black-light').addClass('skin-black');
//   }
// });