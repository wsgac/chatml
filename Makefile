LIBS = -thread unix.cmxa threads.cmxa

FILE := bin/chat

OBJS := src/socket.cmx
OBJS += src/message.cmx
OBJS += src/chat.cmx

all: $(FILE)

bin/%: $(OBJS)
	@mkdir -p bin
	ocamlopt $(LIBS) -o $@ $(OBJS)

%.cmx: %.ml
	@mkdir -p obj
	ocamlopt $(LIBS) -I src/ -c $^

clean:
	@rm -rf $(FILE)
	@rm -rf src/*.cmi
	@rm -rf src/*.o
