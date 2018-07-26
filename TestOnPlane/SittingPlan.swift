//
//  SeatingPlan.swift
//  TestOnPlane
//
//  Created by Billy Chan on 16/4/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

typealias SeatCoords = (row: Int, col: Int)

struct SittingPlan {
	let result: [SeatsInRow]
	
	init?(seatSizes: [[Int]], waitingPassengers passengers: UInt) {
		guard seatSizes.count > 0,
			seatSizes.reduce(true, {(result, size) in result && (size.count >= 2 && size[0] > 0 && size[1] > 0)}) else
		{
			return nil
		}
		
		let rightTailIndex = seatSizes.count - 1
		
		//	Conversion for easier understanding
		let clusterSizes = seatSizes.map{(col: $0[0], row: $0[1])}
		
		//	create seats and grouped into rows
		let allSeatsInRow = clusterSizes.enumerated().map { (arg) -> [SeatsInRow] in
			let groupId = arg.offset
			let clusterSize = arg.element
			let allSeats = (0..<clusterSize.row).map{ row -> SeatsInRow in
				let seats = (0..<clusterSize.col).map{ col -> Seat in
					return Seat(groupId: groupId, coords: SeatCoords(row: row, col: col))
				}
				
				let seatsInRow = SeatsInRow(groupId: groupId, row: row, seats: seats)
				seats.forEach({ seat in
					seat.parentRow = seatsInRow
				})
				
				return seatsInRow
			}
			
			return allSeats
		}
		
		//	Assigning seat type based on arrangements
		var flatRows = allSeatsInRow.flatMap{$0}
		flatRows = flatRows.map {seatsInRow in
			let firstInRow = seatsInRow.seats.first
			let lastInRow = seatsInRow.seats.last
			firstInRow?.type = firstInRow?.groupId == 0 ? .Window : .Aisle
			lastInRow?.type = lastInRow?.groupId == rightTailIndex ? .Window : .Aisle
			
			return seatsInRow
		}
		
		//	Sort the seats by assigning priority
		let seatSortedByType = flatRows.flatMap{$0.seats}.sorted(by: {$0 < $1})
		
		//	Assign passenger into seats
		for i in 0..<min(passengers, UInt(seatSortedByType.count)) {
			seatSortedByType[Int(i)].passengerId = 1 + i
		}
		
		//	Sort the result for better presenting
		self.result = flatRows.sorted(by: {(first, second) in
			if first.row == second.row {
				return first.groupId < second.groupId
			}
			return first.row < second.row
		})
	}
	
	func printResult() {
		self.result.forEach { seatsInRow in
			seatsInRow.seats.forEach{ seat in
				print("\(seat.groupId):(\(seat.coords.row), \(seat.coords.col)) type:\(seat.type) passenger: \(seat.passengerId == nil ? "Empty" : String(describing: seat.passengerId!))")
			}
			print()
		}
	}
}

class SeatsInRow {
	let groupId: Int
	let row: Int
	var seats: [Seat]
	
	init(groupId: Int, row: Int, seats: [Seat]) {
		self.groupId = groupId
		self.row = row
		self.seats = seats
	}
}

class Seat: Comparable {
	static func < (lhs: Seat, rhs: Seat) -> Bool {
		func compareType(_ lhs: Seat, _ rhs: Seat) -> Bool {
			return lhs.type.rawValue == rhs.type.rawValue ? compareRow(lhs, rhs) : lhs.type.rawValue < rhs.type.rawValue
		}
		
		func compareRow(_ lhs: Seat, _ rhs: Seat) -> Bool {
			return lhs.coords.row == rhs.coords.row ? compareGroupId(lhs, rhs) : lhs.coords.row < rhs.coords.row
		}
		
		func compareGroupId(_ lhs: Seat, _ rhs: Seat) -> Bool {
			return lhs.groupId == rhs.groupId ? compareCol(lhs, rhs) : lhs.groupId < rhs.groupId
		}
		
		func compareCol(_ lhs: Seat, _ rhs: Seat) -> Bool {
			return lhs.coords.col < lhs.coords.row
		}
		
		return compareType(lhs, rhs)
	}
	
	static func == (lhs: Seat, rhs: Seat) -> Bool {
		return lhs.groupId == rhs.groupId &&
		lhs.coords.row == lhs.coords.row &&
		lhs.coords.col == lhs.coords.col
	}
	
	enum Category: Int {
		case Aisle
		case Window
		case Middle
	}
	
	let groupId: Int
	let coords: SeatCoords

	var type = Category.Middle
	var passengerId: UInt?
	
	//	Reserved for tracing
	weak var parentRow: SeatsInRow?
	
	init(groupId: Int, coords: SeatCoords) {
		self.groupId = groupId
		self.coords = coords
	}
}


