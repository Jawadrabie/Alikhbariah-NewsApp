import urllib.request
import re

try:
    req = urllib.request.Request(
        'https://alikhbariah.com/live/', 
        data=None, 
        headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
        }
    )
    with urllib.request.urlopen(req) as response:
        html = response.read().decode('utf-8')
        iframes = re.findall(r'<iframe.*?>', html)
        print("Found iframes:", iframes)
        # print first 2000 chars of html just in case
        print(html[:2000])
        print("--- SEARCH FOR YOUTUBE ---")
        youtube_matches = re.findall(r'src="https://www\.youtube\.com/embed/([^"]+)"', html)
        print("YouTube Embeds:", youtube_matches)
        
except Exception as e:
    print(e)
