//
//  Lighting.swift
//  Oko Future
//
//  Created by Денис Калинин on 10.05.23.
//

import RealityKit

final class Lighting: Entity, HasPointLight {
    
    required init() {
        super.init()
        
        self.light = PointLightComponent(color: .white,
                                     intensity: 10000,
                             attenuationRadius: 50)
    }
    
    func strongLight() -> PointLightComponent {
        return PointLightComponent(color: .white,
                                   intensity: 15000,
                           attenuationRadius: 50)
    }
}

