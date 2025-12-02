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
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

