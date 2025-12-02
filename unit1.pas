unit Unit1;

{$Mode ObjFPC}
{$H+}
{$B-}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ClearButton: TButton;
    Label1: TLabel;
    GuideLabel: TLabel;
    WarningLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ResultCountLabel: TLabel;
    SearchButton: TButton;
    ExcludesEdit: TEdit;
    IncludesEdit: TEdit;
    GreenEdit: TEdit;
    ResultsMemo: TMemo;
    procedure ClearButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
  private
    wordList: TStringList;
    procedure showWarning(const msg: string);
    procedure hideWarning;
    function validateNotEmpty: boolean;
    function validateGreenTerm: boolean;
    function validateLettersOnly(const term: string): boolean;
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

procedure TForm1.ClearButtonClick(Sender: TObject);
begin
  GreenEdit.clear;
  IncludesEdit.clear;
  ExcludesEdit.clear;
  ResultsMemo.clear;

  hideWarning
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  WarningLabel.visible := false;

  wordList := TStringList.create;

  try
    wordList.loadFromFile('words_5letters.txt');
  except
    on e: Exception do
      showMessage('Error loading file: ' + e.message);
  end;

  { showMessage('Loaded ' + intToStr(wordlist.count) + ' words') }
end;

function TForm1.validateNotEmpty: boolean;
begin
  validateNotEmpty := (length(GreenEdit.text) > 0) or (length(IncludesEdit.text) > 0)
end;

function TForm1.validateGreenTerm: boolean;
var
  c: char;
begin
  validateGreenTerm := true;

  for c in GreenEdit.text do
    if not (c in ['A'..'Z', 'a'..'z', '_']) then begin
      validateGreenTerm := false;
      exit
    end;
end;

function TForm1.validateLettersOnly(const term: string): boolean;
var
  c: char;
begin
  validateLettersOnly := true;

  for c in lowerCase(term) do
    if not (c in ['a'..'z']) then begin
      validateLettersOnly := false;
      exit
    end;
end;

procedure TForm1.showWarning(const msg: string);
begin
  WarningLabel.caption := msg;
  WarningLabel.visible := true;

  WarningLabel.top := GuideLabel.top;
  WarningLabel.left := GuideLabel.left;
  WarningLabel.width := GuideLabel.width;
  WarningLabel.height := GuideLabel.height
end;

procedure TForm1.hideWarning;
begin
  WarningLabel.visible := false;
end;

procedure TForm1.SearchButtonClick(Sender: TObject);
var
  greenTerm, includeTerm, excludeTerm: string;
  a: word;
  skip: boolean;
  c: char;
  entry: string;
  currentWordList, nextWordList: TStringList;
begin
  hideWarning;
  { showWarning('Test warning'); }

  { Handle validation }
  if not validateNotEmpty then begin
    showMessage('At least 1 input box must be filled');
    GreenEdit.setFocus;
    exit
  end;

  if not validateGreenTerm then begin
    showMessage('Only letters & underscores are allowed');
    GreenEdit.setFocus;
    exit
  end;

  if not validateLettersOnly(IncludesEdit.text) then begin
    showMessage('Only letters are allowed');
    IncludesEdit.setFocus;
    exit
  end;

  if not validateLettersOnly(ExcludesEdit.text) then begin
    showMessage('Only letters are allowed');
    ExcludesEdit.setFocus;
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

