ActionController::Routing::Routes.draw do |map|
  # named tiny mice resources routes
  map.tinymce_hammer_js '/javascripts/tinymce_hammer.js',
    :controller => 'tinymce/hammer',
    :action => 'combine'

  map.tinymce_hammer_lists_js '/javascripts/tinymce_hammer_list.js',
    :controller => 'tinymce/hammer',
    :action => 'lists'
end
