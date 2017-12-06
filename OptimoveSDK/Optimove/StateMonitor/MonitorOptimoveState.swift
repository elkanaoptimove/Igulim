//
//  Monitor.swift
//  OptimoveSDKDev
//
//  Created by Mobile Developer Optimove on 06/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation


public protocol OptimoveStateDelegate
{
    func didStartLoading()
    func didBecomeActive()
    func didBecomeInvalid(withErrors errors : [OptimoveError])
    
    var id: Int { get }
}

class MonitorOptimoveState
{
    //MARK: - Private Variables
    private let lock: NSLock
    private var componentsState : [Component:State.Component]
    private var sdkState: State.SDK
    {
        didSet
        {
            for (_,delegate) in stateDalegates
            {
                notifyDelegate(delegate)
            }
        }
    }
    private var stateDalegates: [Int : OptimoveStateDelegate]
    
    var initializationErrors: [OptimoveError]?
    {
        didSet
        {
            if initializationErrors?.isEmpty ?? true
            {
               sdkState = .inactive
            }
        }
    }
    
    //MARK: - Constructor
    init(
        componentsState: [Component:State.Component]    = [.optiPush:.unknown,
                                                         .optiTrack:.unknown],
         sdkState :State.SDK                            = .loading,
         stateDalegates: [Int : OptimoveStateDelegate]  = [:]
        )
    {
        LogManager.reportToConsole("Initialize Monitor")
        self.componentsState = componentsState
        self.sdkState = sdkState
        self.stateDalegates = stateDalegates
        self.lock = NSLock()
        LogManager.reportToConsole("Finish initializing Monitor")
    }
    
    //MARK: - Internal Methods
    func update(component: Component, state: State.Component)
    {
        componentsState.updateValue(state, forKey: component)
        // TODO: Synchronize updateSDKState() func 
        updateSDKState()
    }
    
    func getState(of component:Component) -> State.Component?
    {
        return componentsState[component]
    }
    
    func register(stateDelegate: OptimoveStateDelegate)
    {
        notifyDelegate(stateDelegate)
        stateDalegates[stateDelegate.id] = stateDelegate
    }
    
    func unregister(stateDelegate:OptimoveStateDelegate)
    {
        stateDalegates.removeValue(forKey: stateDelegate.id)
    }
    
    func isSdkAvailable() -> Bool
    {
        return sdkState == .active
    }
    
    func isComponentPubliclyAvailable(_ component: Component) -> Bool
    {
        let state = getState(of: component)
        return state == .active
    }
    
    func isComponentInternallyAvailable(_ component: Component) -> Bool
    {
        let state = getState(of: component)
        return state == .active || state == .activeInternal
    }
    
    //MARK: - Private Methods
    private func updateSDKState()
    {
        var result = State.SDK.active
        
        for (_ ,state) in componentsState
        {
            switch state
            {
            case .unknown, .permitted,.denied:
                return
            case .inactive:
                result = .inactive
            case .active,.activeInternal:
                break
            }
        }
        
        lock.lock()
        sdkState = result
        lock.unlock()
    }
    
    private func notifyDelegate(_ delegate: OptimoveStateDelegate)
    {
        switch sdkState
        {
        case .loading:
            delegate.didStartLoading()
        case .active:
            delegate.didBecomeActive()
        case .inactive:
            delegate.didBecomeInvalid(withErrors: initializationErrors ?? [])
        }
    }
}


