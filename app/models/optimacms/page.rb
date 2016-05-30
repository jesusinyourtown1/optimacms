module Optimacms
  class Page < ActiveRecord::Base
    self.table_name = 'cms_pages'

    belongs_to :layout, :foreign_key => 'layout_id', :class_name => 'Template'
    belongs_to :template, :foreign_key => 'template_id', :class_name => 'Template'
    belongs_to :folder, :foreign_key => 'parent_id', :class_name => 'Page'
    has_many :translations, :foreign_key => 'item_id', :class_name => 'PageTranslation', :dependent => :destroy
    accepts_nested_attributes_for :translations

    #has_many :page_translations
    #accepts_nested_attributes_for :page_translations

    # callbacks
    before_save :_before_save

    # modules
    include Optimacms::MetaContent
    make_meta(Language.all.map(&:lang))


    #
    paginates_per 10

    # search
    searchable_by_simple_filter



    #### save

    def save
      begin
        super
      rescue => e
        #ActiveRecord::RecordInvalid
        false
      end
    end


    #### folder

    def parent_title
      self.folder.title
    end


    ### content

    def content(lang='')
      filename = content_filename_full(lang)
      return nil if filename.nil?
      return '' if !File.exists? filename
      File.read(filename)
    end

    def content=(v, lang='')
      File.open(content_filename_full(lang), "w+") do |f|
        f.write(v)
      end
    end

    def content_page?
      self.controller_action.nil? || self.controller_action.blank?
    end


    def content_filename(lang='')
      return nil if self.name.nil?
      self.name+content_filename_lang_postfix(lang)+'.'+content_filename_ext
    end

    def self.content_filename_dir
      Rails.root.to_s + '/app/views/pages/'
    end

    def content_filename_full(lang)
      f = content_filename(lang)
      return nil if f.nil?
      Page.content_filename_dir + f
    end


    #### search
=begin
    def self.search_by_filter(filter)
      pg = filter.page
      #pg =1 if pg.nil? || pg<=0

      order = filter.order

      if order.empty?
        orderby = 'id'
        orderdir = 'asc'
      else
        orderby = order[0][0]
        orderdir = order[0][1]
      end

      self.where(get_where(filter.data))
        .order(" #{orderby} #{orderdir}")
        .page(pg)

    end

    def self.get_where(values)
      w = '1=1 '
      #w << " AND uid like '#{values['uid']}%' " if values['uid'] && !values['uid'].blank?
      v = values[:title]
      w << " AND title like '%#{v}%' " if v && !v.blank?

      v = values[:parent_id]
      w << " AND parent_id = '#{v}' " if !v!=-1

      w
    end
=end

    def _before_save

      if self.url_changed?
        self.url_parts_count = PageServices::PageRouteService.count_url_parts(self.url)
        self.url_vars_count = PageServices::PageRouteService::count_url_vars(self.url)
        self.parsed_url = PageServices::PageRouteService::parse_url(self.url)
      end
    end



    ##### translations
=begin
    def translations_by_lang
      return @translations_by_lang unless @translations_by_lang.nil?

      @translations_by_lang = {}
      Language.list_with_default.each{|lang| @translations_by_lang[lang] = nil}
      self.translations.all.each { |r|    @translations_by_lang[r.lang] = r }

      @translations_by_lang
    end
=end

    def build_translations
      langs = Language.list_with_default
      langs_missing = langs - self.translations.all.map{|r| r.lang}

      langs_missing.each do |lang|
        self.translations.new(:lang=>lang)
      end

    end



    ##### meta

    private

    def content_filename_lang_postfix(lang)
      return '' if lang==''
      return '.'+lang
    end

    def content_filename_ext
      return 'html'
    end


  end
end