module Tinymce::Hammer::ViewHelpers

  # If you call this method in your document head two script tags will be
  # inserted when tinymce is required, otherwise nothing will be inserted.
  def init_tinymce_hammer_if_required
    if tinymce_hammer_required?
      tinymce_hammer_javascript_tags
    else
      nil
    end
  end

  def init_tinymce_hammer
    tinymce_hammer_javascript_tags
  end

  # Returns init javascript file
  # If introduced in the js controler we could included in combine action
  def tinymce_hammer_init_javascript
    Tinymce::Hammer.custom_config_setup  # load the custom config file if exists
    init = Tinymce::Hammer.init.collect{|key,value| "#{key} : #{value.to_json}" }.join(",\n")
    lists = Tinymce::Hammer.lists_url.collect { |key,value| "init.#{key} = '#{tinymce_hammer_lists_js_url(value)}';" }.join(",\n") unless Tinymce::Hammer.lists_url.empty?
    setup = "init.setup = #{Tinymce::Hammer.setup};" if Tinymce::Hammer.setup
    <<-eos
      TinymceHammer = {
        init : function() {
          var init = { #{init} };
          init.mode    = 'textareas';
          init.editor_selector = 'tinymce';
          init.plugins = '#{Tinymce::Hammer.plugins.join(',')}';
          init.language = '#{Tinymce::Hammer.languages.first}';
          #{lists}
          #{setup}

          tinyMCE.init(init);
        },
        addEditor : function(dom_id) { // adds tinyMCE editor on the dom_id NOTE: the dom must be a textarea element
          tinyMCE.execCommand('mceAddControl', true, dom_id);
        },
        removeEditor : function(dom_id) { // use this for submiting info to the server backend from the editor
          tinyMCE.triggerSave();
          tinyMCE.execCommand('mceRemoveControl', true, dom_id);
        },
        resetEditor : function(dom_id) { // returns textarea in it normal state
          tinyMCE.execCommand('mceRemoveControl', true, dom_id);
          $('#'+dom_id).reset(); // the jQuery code
          //$(dom_id).reset();   // the Prototype code
        },
        loaderEditor : function() {
          return tinyMCE.ScriptLoader();
        }
      }
      DomReady.ready(TinymceHammer.init);
    eos
  end

  # Returns two script tags.  The first loads the combined jquery-tinymce javascript file
  # The second tag initializes tiny mce.
  # NOTE: Jquery it self must be loaded
  def tinymce_hammer_jquery_javascript_tags
    res = "<script src='#{Tinymce::Hammer.url_path}/jquery.tinymce.js' type='text/javascript'></script>\n"
    # <script type='text/javascript'>#{tinymce_hammer_init_javascript}</script>"
    res += javascript_tag "#{tinymce_hammer_init_javascript}"

    res
  end

  # Returns two script tags.  The first loads the combined javascript file
  # containing tinymce.  The second tag initializes tiny mce.
  def tinymce_hammer_javascript_tags
    res = "<script src='#{tinymce_hammer_js_path}' type='text/javascript'></script>\n"
# <script type='text/javascript'>#{tinymce_hammer_init_javascript}</script>"
    res += javascript_tag "#{tinymce_hammer_init_javascript}"

    res
  end

  def tinymce_tag name, content = '', options = {}
    require_tinymce_hammer
    append_class_name(options, 'tinymce')
    text_area_tag(name, content, options)
  end

  def tinymce object_name, method, options = {}
    require_tinymce_hammer
    append_class_name(options, 'tinymce')
    text_area(object_name, method, options)
  end

  def append_class_name options, class_name #:nodoc:
    key = options.has_key?('class') ? 'class' : :class
    unless options[key].to_s =~ /(^|\s+)#{class_name}(\s+|$)/
      options[key] = "#{options[key]} #{class_name}".strip
    end
    options
  end

end
