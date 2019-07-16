//
//  CompressVideo.swift
//  PoliDash
//
//  Created by David Minasyan on 11.08.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import AVKit

func convertVideoToLowQuailtyWithInputURL(inputURL: NSURL, outputURL: NSURL, onDone: @escaping () -> ()) {
    //setup video writer
    let videoAsset = AVURLAsset(url: inputURL as URL, options: nil)
    let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
    let videoSize = videoTrack.naturalSize
    let videoWriterCompressionSettings = [
        AVVideoAverageBitRateKey : Int(125000)
    ]
    
    let videoWriterSettings:[String : AnyObject] = [
        AVVideoCodecKey : AVVideoCodecH264 as AnyObject,
        AVVideoCompressionPropertiesKey : videoWriterCompressionSettings as AnyObject,
        AVVideoWidthKey : Int(videoSize.width) as AnyObject,
        AVVideoHeightKey : Int(videoSize.height) as AnyObject
    ]
    
    let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoWriterSettings)
    videoWriterInput.expectsMediaDataInRealTime = true
    videoWriterInput.transform = videoTrack.preferredTransform
    let videoWriter = try! AVAssetWriter(outputURL: outputURL as URL, fileType: AVFileType.mp4)
    videoWriter.add(videoWriterInput)
    //setup video reader
    let videoReaderSettings:[String : AnyObject] = [
        kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) as AnyObject
    ]
    
    let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
    let videoReader = try! AVAssetReader(asset: videoAsset)
    videoReader.add(videoReaderOutput)
    //setup audio writer
    let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
    audioWriterInput.expectsMediaDataInRealTime = false
    videoWriter.add(audioWriterInput)
    //setup audio reader
    let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
    let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
    let audioReader = try! AVAssetReader(asset: videoAsset)
    audioReader.add(audioReaderOutput)
    videoWriter.startWriting()
    
    
    
    
    
    //start writing from video reader
    videoReader.startReading()
    videoWriter.startSession(atSourceTime: kCMTimeZero)
    let processingQueue = DispatchQueue(label: "processingQueue1")
    videoWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
        while videoWriterInput.isReadyForMoreMediaData {
            let sampleBuffer:CMSampleBuffer? = videoReaderOutput.copyNextSampleBuffer();
            if videoReader.status == .reading && sampleBuffer != nil {
                videoWriterInput.append(sampleBuffer!)
            }
            else {
                videoWriterInput.markAsFinished()
                if videoReader.status == .completed {
                    //start writing from audio reader
                    audioReader.startReading()
                    videoWriter.startSession(atSourceTime: kCMTimeZero)
                    let processingQueue = DispatchQueue(label: "processingQueue2")
                    audioWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
                        while audioWriterInput.isReadyForMoreMediaData {
                            let sampleBuffer:CMSampleBuffer? = audioReaderOutput.copyNextSampleBuffer()
                            if audioReader.status == .reading && sampleBuffer != nil {
                                audioWriterInput.append(sampleBuffer!)
                            }
                            else {
                                audioWriterInput.markAsFinished()
                                if audioReader.status == .completed {
                                    videoWriter.finishWriting(completionHandler: {() -> Void in
                                        onDone();
                                    })
                                }
                            }
                        }
                    })
                }
            }
        }
    })
}
