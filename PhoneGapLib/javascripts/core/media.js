

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

/**
 * Media/Audio override.
 *
 */

function Media(src, successCallback, errorCallback, downloadCompleteCallback) {
    this.src = src;
    this.successCallback = successCallback;
    this.errorCallback = errorCallback;
    this.downloadCompleteCallback = downloadCompleteCallback;
    
    if (this.src != null) {
	PhoneGap.exec("Sound.prepare", this.src, this.successCallback, this.errorCallback, this.downloadCompleteCallback);
    }
}

Media.fadeInCallbacks = {};
Media.fadeOutCallbacks = {};

Media.prototype.play = function(options) {
    if (this.src != null) {
	PhoneGap.exec("Sound.play", this.src, options);
    }
};

Media.prototype.pause = function() {
    if (this.src != null) {
	PhoneGap.exec("Sound.pause", this.src);
    }
};

Media.prototype.stop = function() {
    if (this.src != null) {
	PhoneGap.exec("Sound.stop", this.src);
    }
};

Media.prototype.playAndFadeIn = function(duration, callback) {
    if (this.src != null) {
	var that = this;
	Media.fadeInCallbacks[this.src] = callback || function () {};
	PhoneGap.exec("Sound.playAndFadeIn", this.src, duration);
    }
};

Media.prototype.fadeOutAndStop = function(duration, callback) {
    if (this.src != null) {
	Media.fadeOutCallbacks[this.src] = callback || function () {};
	PhoneGap.exec("Sound.fadeOutAndStop", this.src, duration);
    }
};
