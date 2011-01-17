
/**
 * This class provides access to the device orientation.
 * @constructor
 */
function Orientation() {
	/**
	 * The current orientation, or null if the orientation hasn't changed yet.
	 */
	this.currentOrientation = null;
}

/**
 * Set the current orientation of the phone.  This is called from the device automatically.
 * 
 * When the orientation is starting to change the DOMEvent \c
 * orientationChanging is dispatched against the document
 * element. When the orientation has changed, the DOMEvent \c
 * orientationChanged is dispatched against the document element.
 * Both events have the property \c orientation which can be used to
 * retrieve the device's current orientation, in addition to the \c
 * Orientation.currentOrientation class property.
 *
 * @param {Number} orientation The orientation to be set
 */
Orientation.prototype.setOrientation = function(orientation) {
    Orientation.currentOrientation = orientation;
};

Orientation.prototype.triggerOrientationChanging = function () {
    var e = document.createEvent('Events');
    e.initEvent('orientationChanging', 'false', 'false');
    e.orientation = Orientation.currentOrientation;
    document.dispatchEvent(e);
};

Orientation.prototype.triggerOrientationChanged = function () {
    var e = document.createEvent('Events');
    e.initEvent('orientationChanged', 'false', 'false');
    e.orientation = Orientation.currentOrientation;
    document.dispatchEvent(e);
};

/**
 * Asynchronously aquires the current orientation.
 * @param {Function} successCallback The function to call when the orientation
 * is known.
 * @param {Function} errorCallback The function to call when there is an error 
 * getting the orientation.
 */
Orientation.prototype.getCurrentOrientation = function(successCallback, errorCallback) {
	// If the position is available then call success
	// If the position is not available then call error
};

/**
 * Asynchronously aquires the orientation repeatedly at a given interval.
 * @param {Function} successCallback The function to call each time the orientation
 * data is available.
 * @param {Function} errorCallback The function to call when there is an error 
 * getting the orientation data.
 */
Orientation.prototype.watchOrientation = function(successCallback, errorCallback) {
	// Invoke the appropriate callback with a new Position object every time the implementation 
	// determines that the position of the hosting device has changed. 
	this.getCurrentPosition(successCallback, errorCallback);
	return setInterval(function() {
		navigator.orientation.getCurrentOrientation(successCallback, errorCallback);
	}, 10000);
};

/**
 * Clears the specified orientation watch.
 * @param {String} watchId The ID of the watch returned from #watchOrientation.
 */
Orientation.prototype.clearWatch = function(watchId) {
	clearInterval(watchId);
};

PhoneGap.addConstructor(function() {
    if (typeof navigator.orientation == "undefined") navigator.orientation = new Orientation();
});
