import os
import re
import sys

# Màu sắc cho terminal
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_result(status, filename, message):
    if status:
        print(f"{GREEN}[OK]{RESET} {filename} -> {message}")
    else:
        print(f"{RED}[LỖI]{RESET} {filename} -> {message}")

def check_makefile():
    path = "Makefile"
    if not os.path.exists(path):
        return print_result(False, path, "Không tìm thấy file Makefile")
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "arm64e" in content:
        return print_result(False, path, "Vẫn còn arm64e (Dễ lỗi compile, nên xóa)")
    if "$(wildcard ImGui/*.cpp)" not in content and "$(wildcard MenuLoad/*.mm)" not in content:
        return print_result(False, path, "Chưa thêm đường dẫn Wildcard (Kiểm tra lại FILES)")
    
    print_result(True, path, "Cấu hình Theos có vẻ ổn")

def check_plist():
    path = "34306jit.plist"
    if not os.path.exists(path):
        return print_result(False, path, "Không tìm thấy file plist")
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Tìm bundle ID (thường là com.vng.zing.speed hoặc tương tự)
    match = re.search(r'Bundles\s*=\s*\(\s*"(.*?)"\s*\)', content)
    if not match:
        return print_result(False, path, "Cấu trúc Filter Bundles sai")
    
    bundle_id = match.group(1)
    if "com.apple" in bundle_id:
         return print_result(False, path, f"Bundle ID đang là {bundle_id} (Mày đang hook vào Springboard, không phải Zing Speed)")
    
    print_result(True, path, f"Bundle ID hợp lệ: {bundle_id}")

def check_includes():
    path = "MenuLoad/Includes.h"
    if not os.path.exists(path):
        return print_result(False, path, "Không tìm thấy file Includes.h")
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "struct CheatVars" not in content:
        return print_result(False, path, "Thiếu struct CheatVars")
    if "extern CheatVars Cheats;" not in content:
        return print_result(False, path, "Thiếu khai báo extern CheatVars Cheats;")
    
    print_result(True, path, "Đã có struct CheatVars và biến Cheats")

def check_usermenu():
    path = "MenuLoad/UserMenu.mm"
    if not os.path.exists(path):
        # Thử check file .xm
        path = "MenuLoad/UserMenu.xm"
        if not os.path.exists(path):
            return print_result(False, path, "Không tìm thấy UserMenu (.mm hoặc .xm)")
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "Zing Speed Mobile | Dev: Ng The Anh" not in content:
        return print_result(False, path, "Chưa đổi Title Bar (Hoặc chưa dán code mới)")
    if "TeleportOverlay" not in content:
        return print_result(False, path, "Chưa có nút Teleport Overlay")
    
    print_result(True, path, "Giao diện Menu mới đã được nạp")

def check_basichacks():
    path = "Source/BasicHacks.mm"
    if not os.path.exists(path):
        return print_result(False, path, "Không tìm thấy BasicHacks.mm")
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "namespace offsets" not in content:
        return print_result(False, path, "Thiếu namespace offsets")
    if "CheatVars Cheats;" not in content:
        return print_result(False, path, "Thiếu khởi tạo biến Cheats")
    if "OFFSET_GWorld" not in content:
        return print_result(False, path, "Thiếu biến OFFSET_GWorld")
    if "KomaruPatch::ReadMem<uintptr_t>" not in content:
        return print_result(False, path, "Chưa thêm template <uintptr_t> cho ReadMem")
    
    print_result(True, path, "Logic BasicHacks đã chuẩn")

def check_imgui_view():
    path = "MenuLoad/ImGuiDrawView.mm"
    if not os.path.exists(path):
        path = "MenuLoad/ImGuiDrawView.xm"
        if not os.path.exists(path):
             return print_result(False, path, "Không tìm thấy ImGuiDrawView")
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "GetGlyphRangesChineseFull()" in content:
        return print_result(False, path, "Vẫn còn GetGlyphRangesChineseFull() (Nguy cơ văng RAM)")
    
    print_result(True, path, "Đã fix font chống văng")

if __name__ == "__main__":
    print(f"{YELLOW}=== KIỂM TRA CẤU TRÚC BUILD MOD MENU ==={RESET}")
    
    # Kiểm tra mày có đang đứng đúng thư mục gốc không
    if not os.path.exists("Makefile"):
        print(f"{RED}LỖI: Không tìm thấy Makefile ở thư mục hiện tại!{RESET}")
        print("Vui lòng mở CMD/Terminal tại thư mục gốc của project (nơi có file Makefile).")
        sys.exit(1)
        
    check_makefile()
    check_plist()
    check_includes()
    check_usermenu()
    check_basichacks()
    check_imgui_view()
    
    print(f"\n{YELLOW}=== HOÀN TẤT ==={RESET}")