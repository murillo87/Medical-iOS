/// The display interface, which is available to the logic for updating the views.
protocol AmslertestDisplayInterface: class {
	/**
	 Updates the display with given data to show.

	 - parameter model: The data to show.
	 */
	func updateDisplay(model: AmslertestDisplayModel.UpdateDisplay)

	/**
	 Shows an alert to inform about a writing error on the databse.
	 */
	func showDatabaseWriteError()
}
