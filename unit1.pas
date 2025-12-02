unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    SearchButton: TButton;
    ExcludesEdit: TEdit;
    IncludesEdit: TEdit;
    GreenEdit: TEdit;
    ResultsMemo: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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

end.

