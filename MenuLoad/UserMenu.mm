// File: MenuLoad/UserMenu.mm
#include "UserMenu.h"
#include "Includes.h"
#include "imgui.h"
#include "imgui_internal.h"

void UserMenu::RenderingMenu() {
    if (!isMenuOpen) return; 

    // ==========================================
    // CẤU HÌNH GIAO DIỆN (DARK THEME)
    // ==========================================
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 10.0f;
    style.FrameRounding = 6.0f;
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.08f, 0.08f, 0.08f, 0.98f);
    style.Colors[ImGuiCol_TitleBg] = ImVec4(0.12f, 0.12f, 0.12f, 1.0f);
    style.Colors[ImGuiCol_TitleBgActive] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_Text] = ImVec4(0.85f, 0.85f, 0.85f, 1.0f);
    style.Colors[ImGuiCol_Button] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.25f, 0.25f, 0.25f, 1.0f);
    style.Colors[ImGuiCol_ButtonActive] = ImVec4(0.30f, 0.30f, 0.30f, 1.0f);

    ImGui::SetNextWindowSize(ImVec2(600, 420), ImGuiCond_FirstUseEver);
    ImGui::Begin("Zing Speed Mobile | Dev: Ng The Anh", &isMenuOpen, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoSavedSettings);

    // ==========================================
    // SIDEBAR TRÁI (CHỈ GIỮ 3 ICON)
    // ==========================================
    ImGui::BeginChild("Sidebar", ImVec2(60, 0), true);
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.15f, 0.15f, 0.15f, 1.0f));
    
    static int activeTab = 0;
    
    // Icon 1: User (Quản lý hack cơ bản)
    if (activeTab == 0) ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.2f, 0.6f, 1.0f, 1.0f));
    if (ImGui::Button("User", ImVec2(50, 50))) activeTab = 0;
    if (activeTab == 0) ImGui::PopStyleColor();
    ImGui::Spacing();
    
    // Icon 2: Car (Tự động đua, mod xe)
    if (activeTab == 1) ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.2f, 0.6f, 1.0f, 1.0f));
    if (ImGui::Button("Car", ImVec2(50, 50))) activeTab = 1;
    if (activeTab == 1) ImGui::PopStyleColor();
    ImGui::Spacing();
    
    // Icon 3: Settings (Quay phim, fix login, thông tin)
    if (activeTab == 2) ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.2f, 0.6f, 1.0f, 1.0f));
    if (ImGui::Button("Set", ImVec2(50, 50))) activeTab = 2;
    if (activeTab == 2) ImGui::PopStyleColor();
    
    ImGui::PopStyleColor();
    ImGui::EndChild();
    
    ImGui::SameLine();

    // ==========================================
    // NỘI DUNG CHÍNH (TAB TƯƠNG ỨNG)
    // ==========================================
    ImGui::BeginChild("Content", ImVec2(0, 0), false);
    
    // TAB 1: USER (Các tính năng cơ bản: Teleport, Nitro, Tốc độ...)
    if (activeTab == 0) {
        ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.2f, 1.0f), "admin sẽ bổ sung map thiếu khi bạn báo cáo");
        ImGui::TextColored(ImVec4(0.5f, 0.5f, 0.5f, 1.0f), "Đua kín để bảo vệ acc của bạn");
        ImGui::Separator();
        ImGui::Spacing();

        ImGui::Columns(2, nullptr, false);
        ImGui::Checkbox("Teleport Auto", &Cheats.TeleportAuto);
        ImGui::Checkbox("Vo Han Nitro", &Cheats.VoHanNitro);
        ImGui::Checkbox("Gia Toc", &Cheats.GiaToc);
        ImGui::NextColumn();
        ImGui::Checkbox("Teleport Button", &Cheats.TeleportButton);
        ImGui::Checkbox("Mini Boot", &Cheats.MiniBoot);
        ImGui::Checkbox("Nitro Nhanh", &Cheats.NitroNhanh);
        ImGui::Columns(1);
        
        ImGui::Spacing();
        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.1f, 0.1f, 0.1f, 1.0f));
        ImGui::BeginChild("MapInfoBox", ImVec2(0, 60), true);
        ImGui::TextColored(ImVec4(0.8f, 0.8f, 0.8f, 1.0f), "Trang thai: Da ket noi");
        ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.5f, 1.0f), "Map ID: 157 (Ho Long Tinh)");
        ImGui::EndChild();
        ImGui::PopStyleColor();
    }

    // TAB 2: CAR (Các tính năng xe cộ: Auto Đua, Mod Skin, Chỉ số xe)
    else if (activeTab == 1) {
        ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.2f, 1.0f), "Tinh Chinh Xe");
        ImGui::Separator();
        ImGui::Spacing();

        ImGui::Checkbox("Auto Dua Lap Trinh", &Cheats.AutoDuaLapTrinh);
        ImGui::Spacing();
        if (ImGui::RadioButton("1. Theo duong huong dan", Cheats.AutoMode == 1)) { Cheats.AutoMode = 1; }
        if (ImGui::RadioButton("2. Tu ra giua duong", Cheats.AutoMode == 2)) { Cheats.AutoMode = 2; }
        
        ImGui::Spacing();
        ImGui::Separator();
        ImGui::Spacing();

        ImGui::Columns(2, nullptr, false);
        ImGui::Checkbox("Mod Skin", &Cheats.MiniBoot); // Tạm dùng chung biến
        ImGui::Checkbox("Unlock Xe+Skin", &Cheats.GiaToc);
        ImGui::NextColumn();
        ImGui::Checkbox("Mod chi so xe", &Cheats.VoHanNitro);
        ImGui::Columns(1);
        
        ImGui::Spacing();
        if (Cheats.AutoDuaLapTrinh) {
            ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.2f, 1.0f), "Trang thai: DANG TU DONG DUA...");
        } else {
            ImGui::TextColored(ImVec4(1.0f, 0.5f, 0.5f, 1.0f), "Trang thai: DA TAT");
        }
    }

    // TAB 3: SETTINGS (Cài đặt, Ẩn hiện, Fix login)
    else if (activeTab == 2) {
        ImGui::TextColored(ImVec4(0.5f, 0.8f, 1.0f, 1.0f), "Cai Dat He Thong");
        ImGui::Separator();
        ImGui::Spacing();

        ImGui::Checkbox("Che do quay phim / Streamer", &KTempVars.StreamerMode);
        ImGui::Checkbox("An thong bao / Giao dien", &Cheats.ThoatNhanh);
        
        ImGui::Spacing();
        ImGui::Separator();
        ImGui::Spacing();

        ImGui::TextColored(ImVec4(1.0f, 0.5f, 0.5f, 1.0f), "Ho Tro & Fix Loi:");
        if (ImGui::Button("Fix Login Facebook", ImVec2(150, 30))) {
            // Chèn code fix login facebook ở đây
        }
        ImGui::SameLine();
        if (ImGui::Button("Xoa Cache Game", ImVec2(150, 30))) {
            // Chèn code clear cache
        }
        
        ImGui::Spacing();
        ImGui::Separator();
        ImGui::Spacing();
        
        ImGui::TextDisabled("- Menu phat trien boi Ng The Anh.");
        ImGui::TextDisabled("- Zalo: 0338442509");
        ImGui::TextDisabled("- Telegram: @tranggnekk");
    }

    ImGui::EndChild(); // Kết thúc Content
    ImGui::End(); // Kết thúc Window
}
