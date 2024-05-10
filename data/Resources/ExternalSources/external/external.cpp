#include <iostream>
#include <fstream>
#include <string>
#include <Windows.h>
#include <regex>

// absolutely crap program to check dxvk 2.0 compatibility and calculate aspect ratio

void aspectratio()
{
    RECT desktop;
    const HWND hDesktop = GetDesktopWindow();
    GetWindowRect(hDesktop, &desktop);

    int width = desktop.right - desktop.left;
    int height = desktop.bottom - desktop.top;

    int gcd = 0;
    int temp, aspect_width, aspect_height;

    // Calculate aspect ratio
    int a = width;
    int b = height;
    while (b != 0) {
        temp = a % b;
        a = b;
        b = temp;
    }
    gcd = a;

    aspect_width = width / gcd;
    aspect_height = height / gcd;

    std::cout << aspect_width << ":" << aspect_height;
}

short checkVKVersion(const std::string& filePath) {
    std::ifstream file(filePath);
    if (!file.is_open()) {
        std::cerr << "ERROR";
        exit(1);
    }

    std::string line;
	std::regex pattern("	apiVersion        = 1.([0-9]).*");
    int version = 0;
    bool extensionsFound = false;

    while (std::getline(file, line)) {
        std::smatch match;
        if (std::regex_search(line, match, pattern)) {
            int x = std::stoi(match[1].str());
            if (x > version) {
                version = x;
            }
        }
        if (line.find("VK_EXT_robustness2") != std::string::npos ||
            line.find("nullDescriptor      = true") != std::string::npos ||
            line.find("robustBufferAccess2 = true") != std::string::npos) {
            extensionsFound = true;
        }
    }

    file.close();

    if (version >= 3 && extensionsFound) {
        return 1;
    }
    else if (version == 0) {
        return 3;
    }
    else if (0 << version <= 3 && !extensionsFound) {
        return 2;
    }

}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        aspectratio();
        exit(0);
    }

    std::string filePath(argv[1]);

    std::cout << checkVKVersion(filePath);
}