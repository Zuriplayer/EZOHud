EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local HUD_SCENE_NAMES = {
    hud = true,
    hudui = true,
}

local function GetCurrentSceneName()
    if SCENE_MANAGER and type(SCENE_MANAGER.GetCurrentSceneName) == "function" then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER and type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and type(scene.GetName) == "function" then
            return scene:GetName()
        end
        if scene and scene.name then
            return scene.name
        end
    end
end

function EZO_HUD:IsHudSceneVisible()
    local sceneName = GetCurrentSceneName()
    if sceneName then
        return HUD_SCENE_NAMES[sceneName] == true
    end

    return true
end

function EZO_HUD:RegisterHudSceneControl(control)
    if not control or not ZO_SimpleSceneFragment or not HUD_SCENE or not HUD_UI_SCENE then
        return nil
    end

    self.runtime = self.runtime or {}
    self.runtime.hudFragments = self.runtime.hudFragments or {}

    local fragment = self.runtime.hudFragments[control]
    if not fragment then
        fragment = ZO_SimpleSceneFragment:New(control)
        self.runtime.hudFragments[control] = fragment
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)
    end

    return fragment
end

function EZO_HUD:RefreshHudContextVisibility()
    if self.RefreshOverlayVisibility then
        self:RefreshOverlayVisibility()
    end
    if self.RefreshUltimateVisibility then
        self:RefreshUltimateVisibility()
    end
    if self.RefreshExecute then
        self:RefreshExecute()
    end
end

function EZO_HUD:InitializeHudVisibility()
    if SCENE_MANAGER and type(SCENE_MANAGER.RegisterCallback) == "function" then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(_, stateOrOldState, maybeNewState)
            local newState = maybeNewState or stateOrOldState
            if newState == SCENE_SHOWING
                or newState == SCENE_SHOWN
                or newState == SCENE_HIDING
                or newState == SCENE_HIDDEN then
                self:RefreshHudContextVisibility()
            end
        end)
    end
end
