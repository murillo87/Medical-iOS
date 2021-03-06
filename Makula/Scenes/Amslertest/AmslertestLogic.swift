import UIKit

/**
 The logic class of this scene.

 This class is responsible for any logic happening in the scene, all possible states and the data models.
 It is NOT responsible for any presentation, this is what the display is for.
 This class also doesn't need to provide each logic, it may divide it into worker classes.
 The logic functions as the glue between all workers and the display.
 The logic holds all data models necessary to work on in this scene and if needed it provides the data for routing purposes.
 All routings have to be executed via the logic, but be done by the router class which is hold by the logic.
 */
class AmslertestLogic {
	// MARK: - Dependencies

	/// A weak reference to the display.
	private weak var display: AmslertestDisplayInterface?

	/// The strong reference to the router.
	private let router: AmslertestRouterInterface

	/// The data model holding the current scene state.
	var contentData = AmslertestLogicModel.ContentData()

	/// The global data from the content data.
	private var globalData: GlobalData {
		guard let globalData = contentData.globalData else { fatalError() }
		return globalData
	}

	/// A closure which returns true when the device is currently in landscape otherwise false.
	/// Defaultly this returns `UIDevice.current.orientation.isLandscape`.
	var isDeviceOrientationLandscape: () -> Bool = {
		UIDevice.current.orientation.isLandscape
	}

	// MARK: - Init

	/**
	 Sets up the instance with references.

	 - parameter display: The reference to the display, hold weakly.
	 - parameter router: The reference to the router, hold strongly.
	 */
	init(display: AmslertestDisplayInterface, router: AmslertestRouterInterface) {
		self.display = display
		self.router = router
	}
}

// MARK: - AmslertestLogicInterface

extension AmslertestLogic: AmslertestLogicInterface {
	// MARK: - Models

	func setModel(_ model: AmslertestRouterModel.Setup) {
		contentData = AmslertestLogicModel.ContentData()
		contentData.globalData = model.globalData
	}

	// MARK: - Requests

	func requestDisplayData() {
		// Get model.
		if contentData.amslertestModel == nil {
			let today = Date()
			guard let modelResults = globalData.dataModelManager.getAmslertestModel(forDay: today) else { fatalError() }
			if let model = modelResults.first {
				// Found an existing model for the day.
				contentData.amslertestModel = model
			} else {
				// No model for the day, create one temporarily.
				contentData.amslertestModel = globalData.dataModelManager.createAmslertestModel(date: today)
			}
		}

		// Update display.
		let largeStyle = isDeviceOrientationLandscape()
		let displayModel = AmslertestDisplayModel.UpdateDisplay(
			largeStyle: largeStyle,
			amslertestModel: contentData.amslertestModel,
			dataModelManager: globalData.dataModelManager
		)
		display?.updateDisplay(model: displayModel)
	}

	func databaseWriteError() {
		display?.showDatabaseWriteError()
	}

	// MARK: - Actions

	func backButtonPressed() {
		// Delete an empty data model.
		if let model = contentData.amslertestModel, model.progressLeft == nil, model.progressRight == nil {
			if !globalData.dataModelManager.deleteAmslertestModel(model) {
				Log.warn("Deleting an empty amslertest model failed")
			}
			contentData.amslertestModel = nil
		}

		// Route back.
		router.routeBackToMenu()
	}

	func infoButtonPressed() {
		// Perform route.
		let model = InfoRouterModel.Setup(globalData: globalData, sceneType: .amslertest)
		router.routeToInformation(model: model)
	}
}
