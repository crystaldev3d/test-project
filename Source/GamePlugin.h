#pragma once

#include <Urho3D/Engine/StateManager.h>
#include <Urho3D/Graphics/Viewport.h>
#include <Urho3D/Plugins/PluginApplication.h>
#include <Urho3D/Scene/Scene.h>
#include "Urho3D/Container/ConstString.h"


namespace Urho3D
{

    URHO3D_GLOBAL_CONSTANT(ConstString Category_GamePlugin{ "Component/GamePlugin" });

    class GamePlugin : public MainPluginApplication
    {
        URHO3D_OBJECT(GamePlugin, MainPluginApplication);


    public:
        /// Construct.
        explicit GamePlugin(Context* context);

    protected:
        /// Implement MainPluginApplication
        /// @{
        void Load() override;
        void Start(bool isMain) override;
        void Stop() override;
        void Unload() override;
        /// @}

    private:
        SharedPtr<Viewport> viewport_;
        SharedPtr<Scene> scene_;
        SharedPtr<Node> cameraNode_;
    };


}
