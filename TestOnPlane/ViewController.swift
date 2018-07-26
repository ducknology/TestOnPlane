//
//  ViewController.swift
//  TestOnPlane
//
//  Created by Billy Chan on 16/4/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let seatSizes = [[3,4], [4,5], [2,3], [3,4]]
		let passengerCount = UInt(48)

		let plan = SittingPlan(seatSizes: seatSizes, waitingPassengers: passengerCount)
		plan == nil ? print("Invalid data") : plan!.printResult()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

