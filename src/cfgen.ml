(*
 * Copyright (c) 2014 Daniil Baturin
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)

open Grammar

type cmd_action = Dump | Reduce

let () = Random.self_init()

let () = let filename = ref "" and
    separator = ref " " and
    start_symbol = ref "start" and
    action = ref Reduce in
    let args = [
        ("--dump-rules", Arg.Unit (fun () -> action := Dump),
         "Dump production rules and exit");
        ("--separator", Arg.String (fun s -> separator := s),
         "<string>    Token separator for generated output, default is space");
        ("--start", Arg.String (fun s -> start_symbol := s),
        "<string>    Start symbol, default is \"start\"");
    ] in let usage = Printf.sprintf "Usage: %s [OPTIONS] <BNF file>" Sys.argv.(0) in
    if Array.length Sys.argv = 1 then
        begin
            Arg.usage args usage;
            exit 1
        end
    else
        begin
            Arg.parse args (fun f -> filename := f) usage;
            let input = open_in !filename in
            let filebuf = Lexing.from_channel input in
            try
                let g = Bnf_parser.grammar Bnf_lexer.token filebuf in
                if !action = Dump then print_endline (string_of_rules g)
                else print_endline (reduce !start_symbol g !separator)
            with
            | Bnf_lexer.Error msg ->
                Printf.eprintf "%s%!" msg
            | Bnf_parser.Error  ->
                Printf.eprintf "At offset %d: syntax error.\n%!" (Lexing.lexeme_start filebuf)
        end
