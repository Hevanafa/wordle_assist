unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    GuideLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ResultCountLabel: TLabel;
    SearchButton: TButton;
    ExcludesEdit: TEdit;
    IncludesEdit: TEdit;
    GreenEdit: TEdit;
    ResultsMemo: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GuideLabelClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
  private
    wordList: TStringList;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  wordList.free;
  wordList := nil;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  wordList := TStringList.create;

  try
    wordList.loadFromFile('words_5letters.txt');
  except
    on e: Exception do
      showMessage('Error loading file: ' + e.message);
  end;

  { showMessage('Loaded ' + intToStr(wordlist.count) + ' words') }
end;

procedure TForm1.GuideLabelClick(Sender: TObject);
begin

end;

procedure TForm1.Label3Click(Sender: TObject);
begin

end;

procedure TForm1.Label4Click(Sender: TObject);
begin

end;

procedure TForm1.SearchButtonClick(Sender: TObject);
var
  greenTerm, includeTerm, excludeTerm: string;
  a: word;
  idx: integer;
  skip: boolean;
  c: char;
  entry: string;
  currentWordList, nextWordList: TStringList;
begin
  if (length(GreenEdit.text) = 0) and (length(IncludesEdit.text) = 0) then begin
    showMessage('At least 1 input box must be filled');
    exit
  end;

  currentWordList := TStringList.create;
  currentWordList.assign(wordList);
  nextWordList := TStringList.create;

  ResultsMemo.lines.clear;

  { Correct letters }
  greenTerm := upperCase(GreenEdit.text);
  
  for entry in currentWordList do begin
    skip := false;
    
    for a:=1 to length(greenTerm) do
      if greenTerm[a] in ['A'..'Z'] then
        if entry[a] <> greenTerm[a] then begin
          skip := true;
          break
        end;

    if skip then continue;

    nextWordList.add(entry)
  end;

  currentWordList.clear;
  currentWordList.assign(nextWordList);
  nextWordList.clear;

  { Included letters }
  includeTerm := upperCase(IncludesEdit.text);

  for c in includeTerm do begin
    nextWordList.clear;

    for entry in currentWordList do
      if pos(c, entry) > 0 then
        nextWordList.add(entry);

    currentWordList.clear;
    currentWordList.assign(nextWordList);
  end;

  { Excluded letters }
  excludeTerm := upperCase(ExcludesEdit.text);
  nextWordList.clear;

  for entry in currentWordList do begin
    skip := false;

    for c in excludeTerm do
      if pos(c, entry) > 0 then begin
        skip := true;
        break
      end;

    if not skip then
      nextWordList.add(entry);
  end;

  currentWordList.clear;
  currentWordList.assign(nextWordList);


  { Result }
  ResultCountLabel.caption := 'Found ' + intToStr(currentWordList.count) + ' words';

  { for entry in currentWordList do
    ResultsMemo.lines.add(entry); }

  ResultsMemo.lines.addStrings(currentWordList);

  nextWordList.free;
  nextWordList := nil;
  currentWordList.free;
  currentWordList := nil
end;

end.

