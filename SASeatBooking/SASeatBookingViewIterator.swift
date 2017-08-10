
import Foundation
import UIKit

struct SASeatBookingViewIterator : IteratorProtocol {
    let size : SASeatBookingSize
    var currentPosition : SASeatPosition?
    init(size : SASeatBookingSize) {
        self.size = size
        self.currentPosition = (0,0)
    }
    
    mutating func next() -> SASeatPosition? {
        
        guard let position = self.currentPosition else {
            return nil
        }
        
        let (newColumn,newRow) = position
        if newColumn < size.columns-1 {
            self.currentPosition = (newColumn+1,newRow)
        }
        else if newRow < size.rows-1 {
            self.currentPosition = (0,newRow+1)
        }
        else {
            self.currentPosition = nil
        }
        return position
    }
}


struct SASeatBookingSequence : Sequence {
    let size : SASeatBookingSize
    init(size : SASeatBookingSize) {
        self.size = size
    }
    
    func makeIterator() -> SASeatBookingViewIterator {
        return SASeatBookingViewIterator(size:self.size)
    }
}
