

/**
 * This class contains information about any Media errors.
 * @constructor
 */
function MediaError(code, message) {
    this.code = code,
    this.message = message;
};

MediaError.MEDIA_ERR_ABORTED = 1;
MediaError.MEDIA_ERR_NETWORK = 2;
MediaError.MEDIA_ERR_DECODE = 3;
MediaError.MEDIA_ERR_NONE_SUPPORTED = 4;

Media.successCallbacks = {};
Media.errorCallbacks = {};
Media.downloadCompleteCallbacks = {};
Media.fadeInCallbacks = {};
Media.fadeOutCallbacks = {};

function Media(src, successCallback, errorCallback, downloadCompleteCallback) {
    this.src = src;

    Media.successCallbacks[src] = successCallback || function() {};
    Media.errorCallbacks[src] = errorCallback || function() {};
    Media.downloadCompleteCallbacks[src] = downloadCompleteCallback || function() {};
    
    if (this.src != null) {
	PhoneGap.exec("Sound.prepare", this.src);
    } else { 
	throw "Invalid state of media object";
    }
}

Media.prototype.play = function(options) {
    if (this.src != null) {
	PhoneGap.exec("Sound.play", this.src, options);
    } else { 
	throw "Invalid state of media object";
    } 
};

Media.prototype.pause = function() {
    if (this.src != null) {
	PhoneGap.exec("Sound.pause", this.src);
    } else { 
	throw "Invalid state of media object";
    }
};

Media.prototype.stop = function() {
    if (this.src != null) {
	PhoneGap.exec("Sound.stop", this.src);
    } else { 
	throw "Invalid state of media object";
    }
};

Media.prototype.playAndFadeIn = function(duration, callback) {
    if (this.src != null) {
	var that = this;
	Media.fadeInCallbacks[this.src] = callback || function () {};
	PhoneGap.exec("Sound.playAndFadeIn", this.src, duration);
    } else { 
	throw "Invalid state of media object";
    }
};

Media.prototype.fadeOutAndStop = function(duration, callback) {
    if (this.src !== null) {
	Media.fadeOutCallbacks[this.src] = callback || function () {};
	PhoneGap.exec("Sound.fadeOutAndStop", this.src, duration);
    } else { 
	throw "Invalid state of media object";
    }
};
 
Media.prototype.discard = function() {
    if(this.src !== null) {
	this.src = null;

	Media.successCallbacks[this.src] = Media.errorCallbacks[this.src] = Media.downloadCompleteCallbacks[this.src] = Media.fadeInCallbacks[this.src] = Media.fadeOutCallbacks[this.src] = undefined;

	PhoneGap.exec("Sound.discard", this.src); 
    } else { 
	throw "Invalid state of media object";
    }
}