unit Unit1;

{$Mode ObjFPC}
{$H+}
{$B-}
{$ModeSwitch AdvancedRecords}
{$Notes OFF}

interface

uses
  Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, StdCtrls,
  FGL, StrUtils;

type
  TFrequencyPair = record
    term: String[5];
    frequency: longword;

    class operator =(a, b: TFrequencyPair): boolean;
  end;

  TForm1 = class(TForm)
    FrequencyListCheckBox: TCheckBox;
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
    procedure Label1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
  private
    wordList: TStringList;
    frequencyList: specialize TFPGList<TFrequencyPair>;

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

class operator TFrequencyPair.= (a, b: TFrequencyPair): boolean;
begin
  result := (a.term = b.term) and (a.frequency = b.frequency)
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FreeAndNil(wordList);
  FreeAndNil(frequencyList);
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
var
  f: text;
  freqpair: TFrequencyPair;
  line: string;
  parts: array of string;
begin
  WarningLabel.visible := false;

  wordList := TStringList.create;

  try
    wordList.loadFromFile('words_5letters.txt');
  except
    on e: Exception do
      showMessage('Error loading file: ' + e.message);
  end;

  { Load the word frequency list }

  frequencyList := specialize TFPGList<TFrequencyPair>.create;
  AssignFile(f, 'freqlist_5letters.txt');
  {$I-} reset(f); {$I+}

  while not eof(f) do begin
    readln(f, line);
    parts := line.Split(',');

    freqpair.term := parts[0];
    freqpair.frequency := StrToInt(parts[1]);

    frequencyList.Add(freqpair)
  end;

  CloseFile(f);

  { showMessage('Loaded ' + intToStr(wordlist.count) + ' words') }
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  GreenEdit.SetFocus;
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  IncludesEdit.SetFocus;
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  ExcludesEdit.SetFocus;
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
  conflictingLetters: string;
  a: word;
  skip: boolean;
  c: char;
  entry: string;
  currentWordList, nextWordList: TStringList;
  useFrequencyList: boolean;
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

  { Check excluded }
  greenTerm := upperCase(GreenEdit.text);
  includeTerm := upperCase(IncludesEdit.text);
  excludeTerm := upperCase(ExcludesEdit.text);

  conflictingLetters := '';

  for c in excludeTerm do begin
    if pos(c, greenTerm) > 0 then
      conflictingLetters := conflictingLetters + c;

    if (pos(c, includeTerm) > 0) and
      (pos(c, conflictingLetters) = 0) then
      conflictingLetters := conflictingLetters + c;
  end;

  if conflictingLetters <> '' then
    showWarning(
      'Warning: Letters ' + conflictingLetters + ' are both excluded ' +
      'and included. Results may be unexpected.');

  currentWordList := TStringList.create;
  currentWordList.assign(wordList);
  nextWordList := TStringList.create;

  ResultsMemo.lines.clear;

  { Correct letters }
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
  for c in includeTerm do begin
    nextWordList.clear;

    for entry in currentWordList do
      if pos(c, entry) > 0 then
        nextWordList.add(entry);

    currentWordList.clear;
    currentWordList.assign(nextWordList);
  end;

  { Excluded letters }
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

  { TODO: handle the frequency list }
  useFrequencyList := FrequencyListCheckBox.Checked;

  FreeAndNil(nextWordList);
  FreeAndNil(currentWordList);
end;

end.

