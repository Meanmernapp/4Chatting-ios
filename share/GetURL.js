//
//  GetURL.js
//  Share
//
//  Created by Hitasoft on 15/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

var GetURL = function() {};

GetURL.prototype = {
    
run: function(arguments) {
    arguments.completionFunction({ "currentUrl" : document.URL });
}
};

var ExtensionPreprocessingJS = new GetURL;
