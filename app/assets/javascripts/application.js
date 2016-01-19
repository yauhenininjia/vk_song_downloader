// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

	$(function() {
    $( "#progressbar" ).progressbar({
      value: false
    });
  });

jQuery(document).ready(function($)
{
	$('table').tableScroll({height: 300});
});

$(document).ready(function(){  
  
    //how much items per page to show  
    var show_per_page = 10;  
    //getting the amount of elements inside content div  
    var number_of_items = $('#content').children().size();  
    //calculate the number of pages we are going to have  
    var number_of_pages = Math.ceil(number_of_items/show_per_page);  
  
    //set the value of our hidden input fields  
    $('#current_page').val(0);  
    $('#show_per_page').val(show_per_page);  
  
    //now when we got all we need for the navigation let's make it '  
  
    /* 
    what are we going to have in the navigation? 
        - link to previous page 
        - links to specific pages 
        - link to next page 
    */  
    var navigation_html = '<div class="btn-group"><button type="button" class="btn btn-sm btn-default" onclick="previous();">Prev</button>';  
    navigation_html += '<button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown">Pages<span class="caret"></span></button><ul class="dropdown-menu scrollable-menu" role="menu">'

    var current_link = 0;  
    while(number_of_pages > current_link){  
        navigation_html += '<li><a class="page_link" href="javascript:go_to_page(' + current_link +')" longdesc="' + current_link +'">'+ (current_link + 1) +'</a></li>';  
        current_link++;  
    }  
    navigation_html += '</ul></div>'
    navigation_html += '<button type="button" class="btn btn-sm btn-default" onclick="next();">Next</button>';  
  
    $('#page_navigation').html(navigation_html);  
  
    //add active_page class to the first page link  
    $('#page_navigation ul li .page_link:first').addClass('active_page');  
  
    //hide all the elements inside content div  
    $('#content').children().css('display', 'none');  
  
    //and show the first n (show_per_page) elements  
    $('#content').children().slice(0, show_per_page).css('display', 'block');  
  
});  
  
function previous(){  
  	
    new_page = parseInt($('#current_page').val()) - 1;  
    console.log('current page: ' + parseInt($('#current_page').val()))
    console.log('go to: ' + new_page)
    //if there is an item before the current active link run the function  
    if(/*$('.active_page').prev('.page_link').length==true*/
    	$('.active_page').parent().prev().children().length==true){  
        go_to_page(new_page);  
    }  
  
}  
  
function next(){  
    new_page = parseInt($('#current_page').val()) + 1;  
    console.log('current page: ' + parseInt($('#current_page').val()))
    console.log('go to: ' + new_page)
    //if there is an item after the current active link run the function  
    if(/*$('.active_page').next('.page_link').length==true*/
    	$('.active_page').parent().next().children().length==true){  
        go_to_page(new_page);  
    }  
  
}  
function go_to_page(page_num){  
    //get the number of items shown per page  
    var show_per_page = parseInt($('#show_per_page').val());  
  
    //get the element number where to start the slice from  
    start_from = page_num * show_per_page;  
  
    //get the element number where to end the slice  
    end_on = start_from + show_per_page;  
  
    //hide all children elements of content div, get specific items and show them  
    $('#content').children().css('display', 'none').slice(start_from, end_on).css('display', 'block');  
  
    /*get the page link that has longdesc attribute of the current page and add active_page class to it 
    and remove that class from previously active page link*/  
    $('.page_link[longdesc=' + page_num +']').addClass('active_page').parent().siblings().children('.active_page').removeClass('active_page');  
  
    //update the current page input field  
    $('#current_page').val(page_num);  
}  

