// File: MenuLoad/UserMenu.h
#pragma once

class UserMenu {
public:
    UserMenu(const UserMenu&) = delete;

    static UserMenu& GetInstance() {
        static UserMenu Instance;
        return Instance;
    }

    // BẮT BUỘC PHẢI CÓ BIẾN NÀY ĐỂ BẬT/TẮT MENU
    bool isMenuOpen = true; 

    void DrawMenu();
    void RenderingMenu();
    void Initialize();

private:
    UserMenu() { }
};

static UserMenu& Menu = UserMenu::GetInstance();