require 'httparty'
require 'nokogiri'

class VisitPage
  include HTTParty

  def initialize(url)
    @url = url
  end

  def fetch
    response = self.class.get(@url, headers: { "User-Agent" => "PredictionMaker" })

    if response.code == 200
      split_html(remove_unwanted_nodes(response.body))
    else
      ["Failed to fetch the URL. Status code: #{response.code}"]
    end
  end

  def fetch_visible_text
    response = self.class.get(@url)

    if response.code == 200
      html = Nokogiri::HTML(response.body)
      visible_text = extract_visible_text(html)
      visible_text
    else
      "Failed to fetch the URL. Status code: #{response.code}"
    end
  end

  private

  def extract_visible_text(node)
    return node.text if node.text?

    if node.element? && (node.name.downcase == 'script' || node.name.downcase == 'style')
      return ''
    end

    if node.comment?
      return ''
    end

    node.children.map { |child| extract_visible_text(child).strip }.join(' ')
  end
end

def remove_unwanted_nodes(html)
  document = Nokogiri::HTML(html)

  # Remove script nodes
  document.xpath('//script').each { |node| node.remove }

  # Remove style nodes
  document.xpath('//style').each { |node| node.remove }

  # Remove comment nodes
  document.xpath('//comment()').each { |node| node.remove }

  # Remove head
  document.xpath('//head').each { |node| node.remove }

  # Remove meta nodes
  document.xpath('//meta').each { |node| node.remove }

  # Remove inline CSS styles from all elements
  document.traverse do |node|
    if node.is_a?(Nokogiri::XML::Element) && node.has_attribute?('style')
      node.remove_attribute('style')
    end
  end

  document.to_html.tr("\r\n\t", ' ').gsub(/ {2,}/, ' ')
end

def split_html(html, max_length = 9_000)
  document = Nokogiri::HTML(html)
  chunks = []
  current_chunk = ''
  text_length = 0

  document.traverse do |node|
    if node.text?
      node_text = node.text
      node_length = node_text.length

      if text_length + node_length > max_length
        if current_chunk.strip != ''
          chunks << current_chunk.strip
          current_chunk = ''
          text_length = 0
        end

        if node_length > max_length
          start_index = 0
          while start_index < node_length
            end_index = [start_index + max_length, node_length].min
            chunks << node_text[start_index...end_index].strip
            start_index = end_index
          end
        else
          current_chunk << node_text
          text_length += node_length
        end
      else
        current_chunk << node_text
        text_length += node_length
      end
    end
  end

  chunks << current_chunk.strip if current_chunk.strip != ''

  chunks
end

# puts VisitPage.new("https://www.sportsbettingdime.com/nhl/stanley-cup-odds/").fetch_visible_text
# p VisitPage.new("https://www.thethings.com/post-malone-wedding-plans-yet-baby-daughter/").fetch
