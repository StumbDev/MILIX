#include <iostream>
#include <string>
#include <vector>
#include <cstring>

// Command declarations
void ls_command();
void echo_command(const std::vector<std::string>& args);
void cat_command(const std::vector<std::string>& args);

// Helper function to get command name from argv[0]
std::string get_command_name(const char* argv0) {
    std::string command_name = std::string(argv0);
    size_t last_slash = command_name.find_last_of("\\/");
    if (last_slash != std::string::npos) {
        command_name = command_name.substr(last_slash + 1);
    }
    return command_name;
}

int main(int argc, char* argv[]) {
    // Parse the command based on argv[0]
    std::string command = get_command_name(argv[0]);

    // Argument parsing
    std::vector<std::string> args;
    for (int i = 1; i < argc; i++) {
        args.push_back(std::string(argv[i]));
    }

    // Dispatch based on the command
    if (command == "ls") {
        ls_command();
    } else if (command == "echo") {
        echo_command(args);
    } else if (command == "cat") {
        cat_command(args);
    } else {
        std::cout << "Command not found: " << command << std::endl;
    }

    return 0;
}
