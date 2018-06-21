//
//  ManuallyEnterViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 21/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol ManuallyEnterViewModelInputs {
    var college: PublishSubject<String?> { get }
    var major: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol ManuallyEnterViewModelOutputs {
    var validatedCollegee: Driver<ValidationResult> { get }
    var validatedMajor: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var create: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var setErrorMessage: Driver<String?> { get }
}

public protocol ManuallyEnterViewModelType {
    var inputs: ManuallyEnterViewModelInputs { get }
    var outputs: ManuallyEnterViewModelOutputs { get }
}
