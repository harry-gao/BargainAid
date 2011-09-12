require 'open-uri'

class HomeController < ApplicationController
  
  GOOGLEHOST = "http://translate.google.com";
  GOOGLETRANS = "/translate?hl=en&sl=zh-CN&tl=en&twu=1&u=";
  def index
    @taobao_list = "http://list.taobao.com/browse/cat-0.htm"
  end
  
  def buy
     @bag_target = "http://list.taobao.com/market/bao.htm?spm=556.3209.4315.2&atype=b&cat=50006842,50072686,50072688&style=grid&viewIndex=1&yp4p_page=0&isnew=2&olu=yes&commend=all"
     @shoe_target = "http://www.taobao.com/go/chn/in/lady_shoes.php?TBG=40980.71104.34&=&ad_id=&am_id=&cm_id=1400381505e63ee7b096&pm_id="
     
     target = params["id"];
     if(target != nil)
       puts 'target not null'
       @framesrc='/home/get_translation/?id=' + CGI.escape(target)
     else
       puts 'target null'
        @framesrc='/home/test'
     end

  end
  
  def get_translation ()
    #need to parse inter-mediate google returned file to get the final url
    url = params["id"];
    return if(url == "")
    
    translate_url = ""
    open(GOOGLEHOST + GOOGLETRANS + CGI.escape(url)) do |file|
        content = file.read;
        content.gsub(/(\/translate_p\?hl=en.*)\"\s/) {|match| translate_url = (GOOGLEHOST + match).gsub(/&amp;/,'&').gsub(/\"/,'')}
      end
      
      open(translate_url) do |file|
        content = file.read;
        content.gsub(/\"http:\/\/translate.*\"/) do |match| 
          translate_url = match.gsub(/&amp;/,'&').gsub(/\"/,'')
        end
      end
      content = get_content_from_google(translate_url)
      #logger.debug content
      render :inline => content
  end
  
  #http://translate.googleusercontent.com/translate_c?hl=en&rurl=translate.google.com&sl=zh-CN&tl=en&u=http://s8.taobao.com/search%3Fq%3Dshoe%26commend%3Dall%26pid%3Dmm_10011550_2325296_9002527%26unid%3D0%26mode%3D63%26p4p_str%3Dlo1%253D0%2526lo2%253D0%2526nt%253D1%26ppath%3D20712:28397%26cps%3Dyes%26from%3Dcompass%26navlog%3Dcompass-4-p-20712:28397&usg=ALkJrhhWDtmrEd2hSr9EYUxUqObZN77mdQ
  #/home/buy/?id=http%3A%2F%2Fwww.taobao.com%2Fgo%2Fchn%2Fin%2Flady_shoes.php%3FTBG%3D40980.71104.34%26%3D%26ad_id%3D%26am_id%3D%26cm_id%3D1400381505e63ee7b096%26pm_id%3D
  #/home/wrap?id=http:
  def wrap()
    url = params["id"]
    url = url.gsub(/&amp;/,'&')
    content = get_content_from_google(url)
    #logger.debug content
    render :inline => content
  end
  
  def get_content_from_google(google_trans_url)
    #puts google_trans_url
    open(google_trans_url,"r:binary") do |file|
      content = file.read.encode("utf-8", "GB2312",  :invalid => :replace, :undef => :replace)
      process_content(content);
    end
  end
  
  def search()
    @term = params[:term];
    respond_to do |format|
      format.html do
        taobaoSearchUrl = "http://s8.taobao.com/search?commend=all&q=" + @term;
        target_url = "/home/buy/?id=" + CGI.escape(taobaoSearchUrl)
        redirect_to(target_url)
      end
      format.js
    end
  end
  
  #process the content from google translation
  def process_content(content)
    #remove the google script whose purpose is to improve its translation

    #content.gsub!(/\<script.*?\/\>/m, '')
    #content.gsub!(/\<script.*?\<\/script>/m, '')
    content.gsub!(/\_tipon\(this\)/,'')
    content.gsub!(/_tipoff\(\)/,'')
    content.gsub!(/iframe/, 'div')
    content.gsub!(/target=\"?(_blank|_top)\"?/, '')
    content.gsub!(/div class=\"tb-key\"/, 'div calss=\"tb-key\" style=\"display:none\"')
    content.gsub!(/onclick=\"?.*?\"/, '')
    
    content.gsub!(/href=\"http:\/\/a.tbcdn.cn.*?\"/, '')

    rid_pattern = /src=\"http:\/\/assets.daily.taobao.net.*?\"/
    content.gsub!(rid_pattern, '')
    
    g_pattern = pattern = /(href=\"?)(http:\/\/translate.googleusercontent\.com\/translate.*?)(\"|\s|\>)/
    content.gsub!(g_pattern) do |match|
        " onclick=top.setClass('result_area','loading') " + $1 +  "http://localhost:3000/home/wrap?id=" + CGI.escape($2) + $3
    end
    
    price_pattern = /<strong id=\"?J_StrPrice\"?.*?\>\s*(\d+.\d+)\s*\<\/strong\>/
    match = price_pattern.match(content)
    if match
      session[:price] = $1
    else
      session[:price] = 'none'
    end
    content
  end
  
  def get_price()
    respond_to do |format|
          format.html 
          format.json { render :json =>  {:item_price => session[:price]}.to_json}
        end
  end
  
  def test()
    respond_to do |format|
    format.html {  puts ".......html......"}
    format.js {puts "...js...."}
    end
  end
end
