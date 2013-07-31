class TwitterExampleController < ApplicationController
  
  resource_description do
    name 'TwitterUsers'
    short_description 'Users are at the center of everything Twitter: they follow, they favorite, and tweet & retweet.'
    path '/twitter_example/'
    description "Long description of this resource."
  end
  
  api :GET, '/twitter_example/lookup', 'Return up to 100 users worth of extended information, specified by either ID, screen name, or combination of the two.'
  param :screen_name, String, :desc => 'A comma separated list of screen names, up to 100 are allowed in a single request. You are strongly encouraged to use a POST for larger (up to 100 screen names) requests.'
  param :user_id, Integer, :desc => 'A comma separated list of user IDs, up to 100 are allowed in a single request. You are strongly encouraged to use a POST for larger requests.'
  param :include_entities, String, :desc => 'When set to either <code>true</code>, <code>t</code> or <code>1</code>, each tweet will include a node called "entities,". This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future. See Tweet Entities for more detail on entities.'
  
  description <<-EOS
    Return up to 100 users worth of extended information, specified by either ID, screen name, or combination of the two. The author's most recent status (if the authenticating user has permission) will be returned inline.

    This method is crucial for consumers of the {Streaming API}[link:https://dev.twitter.com/pages/streaming_api]. It's also well suited for use in tandem with friends/ids[link:https://dev.twitter.com/doc/get/friends/ids] and followers/ids[link:https://dev.twitter.com/doc/get/followers/ids].
    
    === Extended description
    There are a few things to note when using this method.

    * You must be following a protected user to be able to see their most recent status update. If you don't follow a protected user their status will be removed.
    * The order of user IDs or screen names may not match the order of users in the returned array.
    * If a requested user is unknown, suspended, or deleted, then that user will not be returned in the results list.
    * You are strongly encouraged to use a POST for larger requests.
  EOS
  def lookup
    render :text => "lookup"
  end
  
  api :GET, '/twitter_example/profile_image/:screen_name', 'Access the profile image in various sizes for the user with the indicated screen_name.'
  param :screen_name, String, :required => true, :desc => 'The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID.'
  param :size, ['bigger','normal','mini','original'], :desc => <<-EOS
    Specifies the size of image to fetch. Not specifying a size will give the default, normal size of 48px by 48px. Valid options include:

    * bigger - 73px by 73px
    * normal - 48px by 48px
    * mini - 24px by 24px
    * original - undefined. This will be the size the image was originally uploaded in. The filesize of original images can be very big so use this parameter with caution.
  EOS
  description <<-EOS
    Access the profile image in various sizes for the user with the indicated screen_name. If no size is provided the normal image is returned.

    This resource does not return JSON or XML, but instead returns a 302 redirect to the actual image resource.

    This method should only be used by application developers to lookup or check the profile image URL for a user. This method must not be used as the image source URL presented to users of your application.
  EOS
  def profile_image
    render :text => "profile_image of '#{params[:screen_name]}'"
  end
  
  api :GET, '/twitter_example/search', 'Runs a search for users similar to Find People button on Twitter.com.'
  param :q, String, :desc => 'The search query to run against people search.', :required => true
  param :page, Integer, :desc => 'Specifies the page of results to retrieve.'
  param :per_page, Integer, :desc => 'The number of people to retrieve. Maxiumum of 20 allowed per page.'
  param :include_entities, String, :desc => 'When set to either true, t or 1, each tweet will include a node called "entities,". This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future. See Tweet Entities for more detail on entities.'
  description <<-EOS
    Runs a search for users similar to Find People button on Twitter.com. The results returned by people search on Twitter.com are the same as those returned by this API request. Note that unlike GET search, this method does not support any operators.

    Only the first 1000 matches are available.
    
    === Extended description
    This method has a feature-specific rate limit of 60 calls per hour that is applied in conjunction with the main REST API rate limit. Calls to this method will count against the feature-specific rate limit and the main REST API rate limit. If either limit is exhausted, the request will fail. You can monitor the status of the feature-specific rate limit by inspecting the HTTP response headers <tt>X-FeatureRateLimit-Limit</tt>, <tt>X-FeatureRateLimit-Remaining</tt>, and <tt>X-FeatureRateLimit-Reset</tt>. These headers correspond to the <tt>X-RateLimit</tt> headers provided by the main REST API limit.
  EOS

  example <<-EDOC
  [
    {
      "name": "Twitter API",
      "profile_sidebar_border_color": "87bc44",
      "profile_background_tile": false,
      "profile_sidebar_fill_color": "e0ff92",
      "location": "San Francisco, CA",
      "profile_image_url": "http://a3.twimg.com/profile_images/689684365/api_normal.png",
      "created_at": "Wed May 23 06:01:13 +0000 2007",
      "profile_link_color": "0000ff",
      "favourites_count": 2,
      "url": "http://apiwiki.twitter.com",
      "contributors_enabled": true,
      "utc_offset": -28800,
      "id": 6253282,
      "profile_use_background_image": true,
      "profile_text_color": "000000",
      "protected": false,
      "followers_count": 160753,
      "lang": "en",
      "verified": true,
      "profile_background_color": "c1dfee",
      "geo_enabled": true,
      "notifications": null,
      "description": "The Real Twitter API. I tweet about API changes, service issues and happily answer questions about Twitter and our API. Don't get an answer? It's on my website.",
      "time_zone": "Pacific Time (US & Canada)",
      "friends_count": 19,
      "statuses_count": 1858,
      "profile_background_image_url": "http://a3.twimg.com/profile_background_images/59931895/twitterapi-background-new.png",
      "status": {
        "coordinates": null,
        "favorited": false,
        "created_at": "Tue Jun 22 16:53:28 +0000 2010",
        "truncated": false,
        "text": "@Demonicpagan possible some part of your signature generation is incorrect & fails for real reasons.. follow up on the list if you suspect",
        "contributors": null,
        "id": 16783999399,
        "geo": null,
        "in_reply_to_user_id": 6339722,
        "place": null,
        "source": "<a href="http://www.tweetdeck.com" rel="nofollow">TweetDeck</a>",
        "in_reply_to_screen_name": "Demonicpagan",
        "in_reply_to_status_id": 16781827477
      },
      "screen_name": "twitterapi",
      "following": null
    },
    ...
    {
      "name": "twitterAPI",
      "profile_sidebar_border_color": "87bc44",
      "profile_background_tile": false,
      "profile_sidebar_fill_color": "e0ff92",
      "location": null,
      "profile_image_url": "http://s.twimg.com/a/1277162817/images/default_profile_6_normal.png",
      "created_at": "Fri Jun 04 12:07:25 +0000 2010",
      "profile_link_color": "0000ff",
      "favourites_count": 0,
      "url": null,
      "contributors_enabled": false,
      "utc_offset": null,
      "id": 151851125,
      "profile_use_background_image": true,
      "profile_text_color": "000000",
      "protected": false,
      "followers_count": 0,
      "lang": "ja",
      "verified": false,
      "profile_background_color": "9ae4e8",
      "geo_enabled": false,
      "notifications": false,
      "description": null,
      "time_zone": null,
      "friends_count": 0,
      "statuses_count": 0,
      "profile_background_image_url": "http://s.twimg.com/a/1277162817/images/themes/theme1/bg.png",
      "screen_name": "popoAPI",
      "following": false
    }
  ]
  EDOC
  def search
    render :text => 'search'
  end
  
  api :GET, '/twitter_example/:id', 'Returns extended information of a given user, specified by ID or screen name as per the required id parameter.'
  param :id, :number, :required => true, :desc => <<-EOS
    The ID of the user for whom to return results for. Either an id or screen_name is required for this method.
  EOS
  param :screen_name, String, :desc => 'The screen name of the user for...'
  description <<-EDOC
    Returns extended information of a given user, specified by ID or screen name as per the required id parameter. The author's most recent status will be returned inline.
  EDOC
  def show
    render :text => "show #{params}"
  end
  
  api :GET, '/twitter_example/contributors', 'Returns an array of users who can contribute to the specified account.'
  param :user_id, Integer, :desc => 'The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name.'
  param :screen_name, String, :desc => 'The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID.'
  param :include_entities, String
  param :skip_status, ['t','true','1'],
    :description => 'When set to either true, t or 1 statuses will not be included in the returned user objects.'

  description "Look at examples."
  
  example <<-EDOC
    GET https://api.twitter.com/1/twitter_example/contributors.json?screen_name=twitterapi&include_entities=true&skip_status=true
    [
      {
        "profile_sidebar_border_color": "C0DEED",
        "profile_background_tile": false,
        "name": "Matt Harris",
        "profile_sidebar_fill_color": "DDEEF6",
        "expanded_url": "http://themattharris.com",
        "created_at": "Sat Feb 17 20:49:54 +0000 2007",
        "location": "SFO/LHR/YVR/JAX/IAD/AUS",
        "profile_image_url": "http://a1.twimg.com/profile_images/554181350/matt_normal.jpg",
        "follow_request_sent": false,
        "is_translator": false,
        "profile_link_color": "0084B4",
        "id_str": "777925",
        "entities": {
          "urls": [

          ],
          "hashtags": [

          ],
          "user_mentions": [
            {
              "name": "Cindy Li",
              "id_str": "29733",
              "id": 29733,
              "indices": [
                45,
                53
              ],
              "screen_name": "cindyli"
            }
          ]
        },
        "default_profile": true,
        "url": "http://t.co/292MnqA",
        "contributors_enabled": false,
        "favourites_count": 120,
        "id": 777925,
        "utc_offset": -28800,
        "listed_count": 271,
        "profile_use_background_image": true,
        "followers_count": 6242,
        "lang": "en",
        "protected": false,
        "profile_text_color": "333333",
        "profile_background_color": "C0DEED",
        "time_zone": "Pacific Time (US & Canada)",
        "geo_enabled": true,
        "description": "Developer Advocate at Twitter and married to @cindyli. NASA enthusiast, British expat and all around geek living in San Francisco.",
        "notifications": false,
        "verified": false,
        "profile_background_image_url": "http://a0.twimg.com/images/themes/theme1/bg.png",
        "statuses_count": 3835,
        "display_url": "themattharris.com",
        "friends_count": 360,
        "default_profile_image": false,
        "following": false,
        "show_all_inline_media": false,
        "screen_name": "themattharris"
      },
      ...      
    ]
  EDOC
  example <<-EDOC
    Another example...
    {
      "profile_sidebar_border_color": "547980",
      "profile_background_tile": true,
      "name": "Ryan Sarver",
      "profile_sidebar_fill_color": "F8FCF2",
      "expanded_url": "http://sarver.org",
      "created_at": "Mon Feb 26 18:05:55 +0000 2007",
      "location": "San Francisco, CA",
      "profile_image_url": "http://a2.twimg.com/profile_images/644997837/ryan_sarver_twitter_big_normal.jpg",
      "follow_request_sent": false,
      "is_translator": false,
      "profile_link_color": "547980",
      "id_str": "795649",
      "entities": {
        "urls": [

        ],
        "hashtags": [

        ],
        "user_mentions": [

        ]
      },
      "default_profile": false,
      "contributors_enabled": true,
      "url": "http://t.co/Lzsetyk",
      "favourites_count": 246,
      "id": 795649,
      "utc_offset": -28800,
      "profile_use_background_image": true,
      "listed_count": 1384,
      "followers_count": 280756,
      "lang": "en",
      "protected": false,
      "profile_text_color": "594F4F",
      "profile_background_color": "45ADA8",
      "time_zone": "Pacific Time (US & Canada)",
      "geo_enabled": true,
      "description": "platform/api at twitter",
      "notifications": false,
      "verified": false,
      "friends_count": 1022,
      "profile_background_image_url": "http://a0.twimg.com/profile_background_images/113854313/xa60e82408188860c483d73444d53e21.png",
      "display_url": "sarver.org",
      "default_profile_image": false,
      "statuses_count": 7031,
      "following": false,
      "show_all_inline_media": true,
      "screen_name": "rsarver"
    }
  EDOC
  def contributors
    render :text => 'contributors'
  end
  
  def index
    render :text => 'twitter example'
  end
  
end
