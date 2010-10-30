module BreadcrumbsFor
  def breadcrumbs_for *crumbs_list
    list, options = extract_crumb_params(crumbs_list)
    crumbs = []
    crumbs << crumb_html(root_crumb,options,'root') if options[:root]
    crumbs_count = list.size
    list.each_with_index do |crumb,index|
      caption = crumb_to_caption(crumb)
      is_last_crumb = ((index+1) == crumbs_count)
      item = is_last_crumb ? caption : crumb_link(caption, url_for(crumb))
      crumbs << crumb_html(item,options,is_last_crumb ? 'active' : nil)
    end
    crumbs_html(crumbs,options)
  end
  alias :crumbs_for :breadcrumbs_for

  def extract_crumb_params options
    defaults = {
      :root => true,
      :type => :list,
      :sep => '/',
    }
    last_option = options.last
    if last_option.is_a?(Hash) && last_option[:crumbs_options]
      opts = options.pop
      [options, defaults.merge(opts[:crumbs_options])]
    else
      [options, defaults]
    end
  end

  def crumb_html(item,options,pos=nil)
    if options[:type]==:list
      content_tag(:li, item, :class=>"crumb #{pos}")
    else
      item
    end
  end

  def crumbs_html(crumbs,options)
    if options[:type]==:list
      sep = "<li class=\"sep\">#{options[:sep]}</li>"
      raw ['<ul class="breadcrumbs">', crumbs.join(sep), '</ul>'].join
    else
      sep = content_tag(:span, options[:sep], :class=>'sep')
      raw crumbs.join(sep)
    end
  end

  def crumb_link caption, path, options={}
    options[:class] = ['crumb',options[:class]].compact.join(' ')
    link_to(caption, path, options)
  end

  def root_crumb
    crumb_link(root_caption, root_path, :class=>'home_crumb')
  end

  def root_caption
    t("breadcrumbs.root", :default => 'Home' )
  end

  def string_to_caption crumb
    t("breadcrumbs.actions.#{crumb.to_s}", :default => crumb.to_s.capitalize)
  end

  def symbol_caption crumb
    return root_caption if crumb == :root
    t("breadcrumbs.names.#{crumb.to_s}", :default => crumb.to_s.capitalize)
  end

  def array_to_caption crumb
    if crumb.size>1
      case crumb.first.class.to_s
        when 'Symbol' # Is a namespace. Skip it
          cramb_caption(crumb.last)
        when 'String' # Is an action name. Use it
          string_to_caption(crumb.first) << ' ' << cramb_caption(crumb.last)
        else # Use last item only
          cramb_caption(crumb.last)
      end
    else
      cramb_caption(crumb[0])
    end
  end

  def crumb_to_caption crumb
    case crumb.class.to_s
      when 'Symbol'
        symbol_caption(crumb)
      when 'String'
        string_to_caption(crumb)
      when 'Array'
        array_to_caption(crumb)
      when 'Hash'
        crumb.delete(:crumb)
      else
        cramb_caption(crumb)
    end
  end

  def cramb_caption crumb
    if crumb.respond_to?(:title)
      crumb.title
    elsif crumb.respond_to?(:name)
      crumb.name
    else
      crumb.class.to_s.humanize
    end
  end
end

ActionView::Base.send :include, BreadcrumbsFor