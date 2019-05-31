
class Command{
  String command;
  CommandType type;

  Command(this.command, this.type);
}

enum CommandType {
  Send,
  Receive
}