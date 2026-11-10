// File: MenuLoad/UserMenu.mm
#include "UserMenu.h"
#include "Includes.h"
#include "imgui.h"
#include "imgui_internal.h"

void UserMenu::RenderingMenu() {
    if (!isMenuOpen) return; 

    // Cấu hình Style
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 8.0f;
    style.FrameRounding = 4.0f;
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.08f, 0.08f, 0.08f, 0.95f);
    style.Colors[ImGuiCol_TitleBg] = ImVec4(0.12f, 0.12f, 0.12f, 1.0f);
    style.Colors[ImGuiCol_TitleBgActive] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_CheckMark] = ImVec4(0.2f, 1.0f, 0.5f, 1.0f);

    ImGui::SetNextWindowSize(ImVec2(480, 580), ImGuiCond_FirstUseEver);
    ImGui::Begin("Zing Speed Mobile | Dev: Ng The Anh", &isMenuOpen, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoSavedSettings);

    if (ImGui::BeginTabBar("MenuTabs", ImGuiTabBarFlags_None)) {
        
        // ================= TAB 1: GAME CHEATS =================
        if (ImGui::BeginTabItem("Tinh Chinh Game")) {
            ImGui::Spacing();
            ImGui::TextColored(ImVec4(0.5f, 0.8f, 1.0f, 1.0f), "Di Chuyen & Toc Do");
            ImGui::Separator();
            ImGui::Spacing();

            ImGui::Columns(2, nullptr, false);
            ImGui::Checkbox("Vo Han Nitro", &Cheats.VoHanNitro);
            ImGui::Checkbox("Nitro Nhanh", &Cheats.NitroNhanh);
            ImGui::Checkbox("Gia Toc", &Cheats.GiaToc);
            ImGui::NextColumn();
            
            ImGui::Checkbox("Mini Boot", &Cheats.MiniBoot);
            ImGui::Checkbox("Thoat Nhanh", &Cheats.ThoatNhanh);
            ImGui::Columns(1);

            ImGui::Spacing();
            ImGui::Spacing();
            ImGui::TextColored(ImVec4(0.5f, 0.8f, 1.0f, 1.0f), "Teleport & Map");
            ImGui::Separator();
            ImGui::Spacing();

            ImGui::Columns(2, nullptr, false);
            ImGui::Checkbox("Teleport Auto", &Cheats.TeleportAuto);
            ImGui::Checkbox("ECU 3 Luot", &Cheats.ECU3Luot);
            ImGui::NextColumn();
            ImGui::Checkbox("Teleport Button", &Cheats.TeleportButton); 
            ImGui::Checkbox("Fake Ten", &Cheats.FakeTen);
            ImGui::Columns(1);

            ImGui::EndTabItem();
        }

        // ================= TAB 2: AUTO PLAY =================
        if (ImGui::BeginTabItem("Auto Dua")) {
            ImGui::Spacing();
            ImGui::TextColored(ImVec4(0.5f, 0.8f, 1.0f, 1.0f), "He Thong Tu Dong");
            ImGui::Separator();
            ImGui::Spacing();

            ImGui::Checkbox("Auto Dua Lap Trinh", &Cheats.AutoDuaLapTrinh);
            ImGui::Spacing();

            if (ImGui::RadioButton("1. Theo duong huong dan", Cheats.AutoMode == 1)) { Cheats.AutoMode = 1; }
            if (ImGui::RadioButton("2. Tu ra giua duong", Cheats.AutoMode == 2)) { Cheats.AutoMode = 2; }
            
            ImGui::EndTabItem();
        }

        // ================= TAB 3: THONG TIN & LUU Y =================
        if (ImGui::BeginTabItem("Luu Y")) {
            ImGui::Spacing();
            ImGui::Checkbox("Ky Sinh", &Cheats.KySinh);
            ImGui::Checkbox("Streamer Mode", &KTempVars.StreamerMode); 
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.2f, 1.0f), "LUU Y QUAN TRONG:");
            
            ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.12f, 0.12f, 0.12f, 1.0f));
            ImGui::BeginChild("NoteBox", ImVec2(0, 150), true); 
            
            ImGui::TextWrapped("- Menu nay duoc phat trien boi Ng The Anh.");
            ImGui::TextWrapped("- Vui long khong buon ban, chia se mien phi de cong dong phat trien.");
            ImGui::TextWrapped("- Su dung menu co the dan den bi khoa tai khoan. Hay su dung co trach nhiem!");
            ImGui::TextWrapped("- Phien ban: 34306jit v1.0.0");
            
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            ImGui::TextColored(ImVec4(0.5f, 0.8f, 1.0f, 1.0f), "Lien he ho tro:");
            ImGui::TextColored(ImVec4(0.8f, 0.8f, 0.8f, 1.0f), "Zalo: ");
            ImGui::SameLine();
            ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.5f, 1.0f), "0338442509");
            
            ImGui::TextColored(ImVec4(0.8f, 0.8f, 0.8f, 1.0f), "Telegram: ");
            ImGui::SameLine();
            ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.5f, 1.0f), "@tranggnekk");
            
            ImGui::EndChild();
            ImGui::PopStyleColor();

            ImGui::Spacing();
            ImGui::TextDisabled("Copyright © 2024 Ng The Anh.");

            ImGui::EndTabItem();
        }
        
        ImGui::EndTabBar();
    }
    ImGui::End();
}
