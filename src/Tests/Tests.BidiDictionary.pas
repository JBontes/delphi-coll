(*
* Copyright (c) 2011, Ciobanu Alexandru
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

unit Tests.BidiDictionary;
interface
uses SysUtils,
     Tests.Utils,
     TestFramework,
     Generics.Collections,
     Collections.Base,
     Collections.Lists,
     Collections.BidiDictionaries;

type
  TTestBidiDictionary = class(TTestCaseEx)
  published
    procedure TestCreationAndDestroy();
    procedure TestClearAddRemoveCount();
    procedure TestContainsKeyContainsValue();
    procedure TestByKey();
    procedure TestByValue();
    procedure TestValues();
    procedure TestTryGetValue();
    procedure TestTryGetKey();
    procedure TestKeys();
    procedure TestCopyTo();
    procedure TestValuesCopyTo();
    procedure TestKeysCopyTo();
    procedure TestEnumerator();
    procedure TestKeysEnumerator();
    procedure TestValuesEnumerator();
    procedure TestExceptions();
    procedure TestBigSize();
    procedure TestRelations();

    procedure TestObjectVariant();
  end;

implementation

{ TTestBidiDictionary }

procedure TTestBidiDictionary.TestBigSize;
const
  NrElem = 10000;

var
  Dict: TBidiDictionary<Integer, Integer>;
  X: Integer;

  KSum, VSum, VVSum : UInt64;
begin
  KSum := 0;
  VSum := 0;
  Dict := TBidiDictionary<Integer, Integer>.Create();

  for X := 0 to NrElem do
  begin
    Dict.Add(X, X * 2);
    KSum := KSum + X;
    VSum := VSum + (X * 2);
  end;

  VVSum := VSum;

  Check(Dict.Count = NrElem + 1, 'Dictionary Count expected to be ' + IntToStr(NrElem + 1));

  for X in Dict.Keys do
  begin
    KSum := KSum - X;
    VVSum := VVSum - Dict.ByKey[X];
  end;

  for X in Dict.Values do
  begin
    VSum := VSum - X;
  end;

  Check(KSum = 0, 'Dictionary key enumeration failed! Not all keys were found.');
  Check(VVSum = 0, 'Dictionary key/values enumeration failed! Not all values were found.');
  Check(VSum = 0, 'Dictionary values enumeration failed! Not all values were found.');

  Dict.Free;
  { -- check inverse }

  KSum := 0;
  VSum := 0;
  Dict := TBidiDictionary<Integer, Integer>.Create();

  for X := NrElem downto 0 do
  begin
    Dict.Add(X, X * 2);
    KSum := KSum + X;
    VSum := VSum + (X * 2);
  end;

  VVSum := VSum;

  Check(Dict.Count = NrElem + 1, 'Dictionary Count expected to be ' + IntToStr(NrElem + 1));

  for X in Dict.Keys do
  begin
    KSum := KSum - X;
    VVSum := VVSum - Dict.ByKey[X];
  end;

  for X in Dict.Values do
  begin
    VSum := VSum - X;
  end;

  Check(KSum = 0, 'Dictionary key enumeration failed! Not all keys were found.');
  Check(VVSum = 0, 'Dictionary key/values enumeration failed! Not all values were found.');
  Check(VSum = 0, 'Dictionary values enumeration failed! Not all values were found.');


  Dict.Free;
end;

procedure TTestBidiDictionary.TestByKey;
var
  Dict: TBidiDictionary<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(2, 'Col');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Fol');

  CheckEquals('Lol', Dict.ByKey[1]);
  CheckEquals('Col', Dict.ByKey[2]);
  CheckEquals('Zol', Dict.ByKey[3]);
  CheckEquals('Fol', Dict.ByKey[4]);

  Dict.ByKey[1] := 'Mol';
  CheckEquals('Mol', Dict.ByKey[1]);

  Dict.Free;
end;

procedure TTestBidiDictionary.TestByValue;
var
  Dict: TBidiDictionary<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(2, 'Col');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Fol');

  CheckEquals(1, Dict.ByValue['Lol']);
  CheckEquals(2, Dict.ByValue['Col']);
  CheckEquals(3, Dict.ByValue['Zol']);
  CheckEquals(4, Dict.ByValue['Fol']);

  Dict.ByValue['Zol'] := 5;
  CheckEquals(5, Dict.ByValue['Zol']);

  Dict.Free;
end;

procedure TTestBidiDictionary.TestClearAddRemoveCount;
var
  Dict: TBidiDictionary<Integer, String>;

begin
  Dict := TBidiDictionary<Integer, String>.Create();

  { Add items }
  Dict.Add(10, 'String 10');
  Dict.Add(20, 'String 20');
  Dict.Add(30, 'String 30');

  Check((Dict.Count = 3) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 3');

  Dict.Add(15, 'String 15');
  Dict.Add(25, 'String 25');
  Dict.Add(35, 'String 35');

  Check((Dict.Count = 6) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 6');

  Dict.Remove(10);
  Dict.RemoveKey(15);

  Check((Dict.Count = 4) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 4');

  Dict.RemoveValue('String 25');

  Check((Dict.Count = 3) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 3');

  Dict.Clear();

  Check((Dict.Count = 0) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 0');

  Dict.Add(15, 'String 15');

  Check((Dict.Count = 1) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 1');

  Dict.Remove(15, 'String 16');
  Dict.Remove(15, 'String 15');

  Check((Dict.Count = 0) and (Dict.GetCount() = Dict.Count), 'Dcitionary count expected to be 0');

  Dict.Free();
end;

procedure TTestBidiDictionary.TestContainsKeyContainsValue;
var
  Dict: TBidiDictionary<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  { Add items }
  Dict.Add(10, 'String 10');
  Dict.Add(20, 'String 20');
  Dict.Add(30, 'String 30');

  Check(Dict.ContainsKey(10), 'Dictionary expected to contain key 10.');
  Check(Dict.ContainsKey(20), 'Dictionary expected to contain key 20.');
  Check(Dict.ContainsKey(30), 'Dictionary expected to contain key 30.');
  Check(not Dict.ContainsKey(40), 'Dictionary not expected to contain key 40.');

  Check(Dict.ContainsValue('String 10'), 'Dictionary expected to contain value "String 10".');
  Check(Dict.ContainsValue('String 20'), 'Dictionary expected to contain value "String 20".');
  Check(Dict.ContainsValue('String 30'), 'Dictionary expected to contain value "String 30".');
  Check(not Dict.ContainsValue('String 40'), 'Dictionary not expected to contain value "String 40".');

  Dict.Remove(30);

  Check(not Dict.ContainsValue('String 30'), 'Dictionary not expected to contain value "String 30".');
  Check(not Dict.ContainsKey(30), 'Dictionary not expected to contain key 30.');

  Dict.Free();
end;

procedure TTestBidiDictionary.TestKeysCopyTo;
var
  Dict: TBidiDictionary<Integer, String>;
  IL: array of Integer;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
  Dict.Add(5, '5');

  { Check the copy }
  SetLength(IL, 5);
  Dict.Keys.CopyTo(IL);

  Check(IL[0] = 1, 'Element 0 in the new array is wrong!');
  Check(IL[1] = 2, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 3, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 4, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 5, 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Dict.Keys.CopyTo(IL, 1);

  Check(IL[1] = 1, 'Element 1 in the new array is wrong!');
  Check(IL[2] = 2, 'Element 2 in the new array is wrong!');
  Check(IL[3] = 3, 'Element 3 in the new array is wrong!');
  Check(IL[4] = 4, 'Element 4 in the new array is wrong!');
  Check(IL[5] = 5, 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Keys.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyKeysTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Keys.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyKeysTo (too small size +1).'
  );

  Dict.Free();
end;

procedure TTestBidiDictionary.TestKeysEnumerator;
var
  Dict : TBidiDictionary<Integer, Integer>;
  X    : Integer;
  I    : Integer;
begin
  Dict := TBidiDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict.Keys do
  begin
    if X = 0 then
       Check(I = 10, 'Enumerator failed at 0!')
    else if X = 1 then
       Check(I = 20, 'Enumerator failed at 1!')
    else if X = 2 then
       Check(I = 30, 'Enumerator failed at 2!')
    else
       Fail('Enumerator failed!');

    Inc(X);
  end;

  { Test exceptions }


  CheckException(ECollectionChangedException,
    procedure()
    var
      I : Integer;
    begin
      for I in Dict.Keys do
      begin
        Dict.Remove(I);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Dict.Keys.Count = 2, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestBidiDictionary.TestObjectVariant;
var
  ObjDict: TObjecTBidiDictionary<TTestObject, TTestObject>;
  TheKeyObject, TheValueObject: TTestObject;
  KeyDied, ValueDied: Boolean;
begin
  ObjDict := TObjectBidiDictionary<TTestObject, TTestObject>.Create();
  Check(not ObjDict.OwnsKeys, 'OwnsKeys must be false!');
  Check(not ObjDict.OwnsValues, 'OwnsValues must be false!');

  TheKeyObject := TTestObject.Create(@KeyDied);
  TheValueObject := TTestObject.Create(@ValueDied);

  ObjDict.Add(TheKeyObject, TheValueObject);
  ObjDict.Clear;

  Check(not KeyDied, 'The key should not have been cleaned up!');
  Check(not ValueDied, 'The value should not have been cleaned up!');

  ObjDict.Add(TheKeyObject, TheValueObject);

  ObjDict.OwnsKeys := true;
  ObjDict.OwnsValues := true;

  Check(ObjDict.OwnsKeys, 'OwnsKeys must be true!');
  Check(ObjDict.OwnsValues, 'OwnsValues must be true!');

  ObjDict.Clear;

  Check(KeyDied, 'The key should have been cleaned up!');
  Check(ValueDied, 'The value should have been cleaned up!');

  ObjDict.Free;
end;

procedure TTestBidiDictionary.TestRelations;
var
  LDict: TBidiDictionary<Integer, String>;
begin
  LDict := TBidiDictionary<Integer, String>.Create();

  LDict.Add(1, 'John');
  LDict.Add(2, 'Mary');
  LDict.Add(3, 'Michael');
  LDict.Add(4, 'Sally');
  LDict.Add(5, 'Chris');
  LDict.Add(6, 'Ken');
  LDict.Add(7, 'Robert');

  { All relations by value }
  CheckEquals(1, LDict.ByValue['John']);
  CheckEquals(2, LDict.ByValue['Mary']);
  CheckEquals(3, LDict.ByValue['Michael']);
  CheckEquals(4, LDict.ByValue['Sally']);
  CheckEquals(5, LDict.ByValue['Chris']);
  CheckEquals(6, LDict.ByValue['Ken']);
  CheckEquals(7, LDict.ByValue['Robert']);

  { All relations by key }
  CheckEquals('John', LDict.ByKey[1]);
  CheckEquals('Mary', LDict.ByKey[2]);
  CheckEquals('Michael', LDict.ByKey[3]);
  CheckEquals('Sally', LDict.ByKey[4]);
  CheckEquals('Chris', LDict.ByKey[5]);
  CheckEquals('Ken', LDict.ByKey[6]);
  CheckEquals('Robert', LDict.ByKey[7]);

  { Do some changes }
  LDict.ByKey[1] := 'Johnatan';
  LDict.ByKey[6] := 'Kenny';
  LDict.ByValue['Mary'] := 22;
  LDict.ByValue['Chris'] := 55;
  LDict.ByValue['Kenny'] := 66;

  { All relations by value }
  CheckEquals(1, LDict.ByValue['Johnatan']);
  CheckEquals(22, LDict.ByValue['Mary']);
  CheckEquals(3, LDict.ByValue['Michael']);
  CheckEquals(4, LDict.ByValue['Sally']);
  CheckEquals(55, LDict.ByValue['Chris']);
  CheckEquals(66, LDict.ByValue['Kenny']);
  CheckEquals(7, LDict.ByValue['Robert']);

  { All relations by key }
  CheckEquals('Johnatan', LDict.ByKey[1]);
  CheckEquals('Mary', LDict.ByKey[22]);
  CheckEquals('Michael', LDict.ByKey[3]);
  CheckEquals('Sally', LDict.ByKey[4]);
  CheckEquals('Chris', LDict.ByKey[55]);
  CheckEquals('Kenny', LDict.ByKey[66]);
  CheckEquals('Robert', LDict.ByKey[7]);

  LDict.Free;
end;

procedure TTestBidiDictionary.TestTryGetKey;
var
  Dict: TBidiDictionary<Integer, String>;
  Key: Integer;
begin
  Dict := TBidiDictionary<Integer, String>.Create();
  Dict.Add(1, 'One');
  Dict.Add(2, 'Two');
  Dict.Add(3, 'Three');

  Check(Dict.TryGetKey('One', Key), '"One" should have been present in the dictionary!');
  CheckEquals(1, Key);

  Check(Dict.TryGetKey('Two', Key), '"Two" should have been present in the dictionary!');
  CheckEquals(2, Key);

  Check(not Dict.TryGetKey('Four', Key), '"Four" should not have been present in the dictionary!');

  Check(Dict.TryGetKey('Three', Key), '"Three" should have been present in the dictionary!');
  CheckEquals(3, Key);

  Dict.Free;
end;

procedure TTestBidiDictionary.TestTryGetValue;
var
  Dict: TBidiDictionary<Integer, String>;
  Value: String;
begin
  Dict := TBidiDictionary<Integer, String>.Create();
  Dict.Add(1, 'One');
  Dict.Add(2, 'Two');
  Dict.Add(3, 'Three');

  Check(Dict.TryGetValue(1, Value), '1 should have been present in the dictionary!');
  Check(Value = 'One', '1 should have been linked to "One"!');

  Check(Dict.TryGetValue(2, Value), '2 should have been present in the dictionary!');
  Check(Value = 'Two', '2 should have been linked to "Two"!');

  Check(not Dict.TryGetValue(4, Value), '4 should not have been present in the dictionary!');

  Check(Dict.TryGetValue(3, Value), '3 should have been present in the dictionary!');
  Check(Value = 'Three', '3 should have been linked to "Three"!');

  Dict.Free;
end;

procedure TTestBidiDictionary.TestCopyTo;
var
  Dict: TBidiDictionary<Integer, String>;
  IL: array of TPair<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
  Dict.Add(5, '5');
  Dict.Add(6, '6');

  { Check the copy }
  SetLength(IL, 6);
  Dict.CopyTo(IL);

  Check((IL[0].Key = 1) and (IL[0].Value = '1'), 'Element 0 in the new array is wrong!');
  Check((IL[1].Key = 2) and (IL[1].Value = '2'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 3) and (IL[2].Value = '3'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 4) and (IL[3].Value = '4'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 5) and (IL[4].Value = '5'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 6) and (IL[5].Value = '6'), 'Element 5 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 7);
  Dict.CopyTo(IL, 1);

  Check((IL[1].Key = 1) and (IL[1].Value = '1'), 'Element 1 in the new array is wrong!');
  Check((IL[2].Key = 2) and (IL[2].Value = '2'), 'Element 2 in the new array is wrong!');
  Check((IL[3].Key = 3) and (IL[3].Value = '3'), 'Element 3 in the new array is wrong!');
  Check((IL[4].Key = 4) and (IL[4].Value = '4'), 'Element 4 in the new array is wrong!');
  Check((IL[5].Key = 5) and (IL[5].Value = '5'), 'Element 5 in the new array is wrong!');
  Check((IL[6].Key = 6) and (IL[6].Value = '6'), 'Element 6 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyTo (too small size +1).'
  );

  Dict.Free();
end;

procedure TTestBidiDictionary.TestValuesEnumerator;
var
  Dict : TBidiDictionary<Integer, Integer>;
  X    : Integer;
  I    : Integer;
begin
  Dict := TBidiDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict.Values do
  begin
    if X = 0 then
       Check(I = 11, 'Enumerator failed at 0!')
    else if X = 1 then
       Check(I = 21, 'Enumerator failed at 1!')
    else if X = 2 then
       Check(I = 31, 'Enumerator failed at 2!')
    else
       Fail('Enumerator failed!');

    Inc(X);
  end;

  { Test exceptions }


  CheckException(ECollectionChangedException,
    procedure()
    var
      I : Integer;
    begin
      for I in Dict.Values do
      begin
        Dict.ContainsValue(I);
        Dict.Clear();
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Dict.Values.Count = 0, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestBidiDictionary.TestValuesCopyTo;
var
  Dict: TBidiDictionary<Integer, String>;
  IL: array of String;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  { Add elements to the list }
  Dict.Add(1, '1');
  Dict.Add(2, '2');
  Dict.Add(3, '3');
  Dict.Add(4, '4');
  Dict.Add(5, '5');

  { Check the copy }
  SetLength(IL, 5);
  Dict.Values.CopyTo(IL);

  Check(IL[0] = '1', 'Element 0 in the new array is wrong!');
  Check(IL[1] = '2', 'Element 1 in the new array is wrong!');
  Check(IL[2] = '3', 'Element 2 in the new array is wrong!');
  Check(IL[3] = '4', 'Element 3 in the new array is wrong!');
  Check(IL[4] = '5', 'Element 4 in the new array is wrong!');

  { Check the copy with index }
  SetLength(IL, 6);
  Dict.Values.CopyTo(IL, 1);

  Check(IL[1] = '1', 'Element 1 in the new array is wrong!');
  Check(IL[2] = '2', 'Element 2 in the new array is wrong!');
  Check(IL[3] = '3', 'Element 3 in the new array is wrong!');
  Check(IL[4] = '4', 'Element 4 in the new array is wrong!');
  Check(IL[5] = '5', 'Element 5 in the new array is wrong!');

  { Exception  }
  SetLength(IL, 4);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Values.CopyTo(IL); end,
    'EArgumentOutOfSpaceException not thrown in CopyValuesTo (too small size).'
  );

  SetLength(IL, 5);

  CheckException(EArgumentOutOfSpaceException,
    procedure() begin Dict.Values.CopyTo(IL, 1); end,
    'EArgumentOutOfSpaceException not thrown in CopyValuesTo (too small size +1).'
  );

  Dict.Free();
end;

procedure TTestBidiDictionary.TestCreationAndDestroy;
var
  Dict, Dict1: TBidiDictionary<Integer, Integer>;
  IL: array of TPair<Integer, Integer>;
begin
  { With default capacity }
  Dict := TBidiDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);
  Dict.Add(40, 41);

  Check(Dict.Count = 4, 'Dictionary count expected to be 4');

  Dict.Free();

  { With preset capacity }
  Dict := TBidiDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);
  Dict.Add(40, 41);

  Check(Dict.Count = 4, 'Dictionary count expected to be 4');

  Dict.Free();

  { With Copy }
  Dict1 := TBidiDictionary<Integer, Integer>.Create();

  Dict1.Add(101, 111);
  Dict1.Add(201, 211);
  Dict1.Add(301, 311);
  Dict1.Add(401, 411);

  Dict := TBidiDictionary<Integer, Integer>.Create(Dict1);

  Check(Dict.Count = 4, 'Dictionary expected count must be 4');
  Check(Dict.ByKey[101] = 111, 'Dictionary expected value not found');
  Check(Dict.ByKey[201] = 211, 'Dictionary expected value not found');
  Check(Dict.ByKey[301] = 311, 'Dictionary expected value not found');
  Check(Dict.ByKey[401] = 411, 'Dictionary expected value not found');

  Dict.Free();
  Dict1.Free();

  { Copy from array tests }
  SetLength(IL, 5);

  IL[0] := TPair<Integer, Integer>.Create(1, 11);
  IL[1] := TPair<Integer, Integer>.Create(2, 21);
  IL[2] := TPair<Integer, Integer>.Create(3, 31);
  IL[3] := TPair<Integer, Integer>.Create(4, 41);
  IL[4] := TPair<Integer, Integer>.Create(5, 51);

  Dict := TBidiDictionary<Integer, Integer>.Create(IL);

  Check(Dict.Count = 5, 'Dictionary count expected to be 5');

  Check(Dict.ByValue[11] = 1, 'Dict.ByValue[11] expected to be 1');
  Check(Dict.ByValue[21] = 2, 'Dict.ByValue[21] expected to be 2');
  Check(Dict.ByValue[31] = 3, 'Dict.ByValue[31] expected to be 3');
  Check(Dict.ByValue[41] = 4, 'Dict.ByValue[41] expected to be 4');
  Check(Dict.ByValue[51] = 5, 'Dict.ByValue[51] expected to be 5');

  Dict.Free;
end;

procedure TTestBidiDictionary.TestEnumerator;
var
  Dict : TBidiDictionary<Integer, Integer>;
  X    : Integer;
  I    : TPair<Integer, Integer>;
begin
  Dict := TBidiDictionary<Integer, Integer>.Create();

  Dict.Add(10, 11);
  Dict.Add(20, 21);
  Dict.Add(30, 31);

  X := 0;

  for I in Dict do
  begin
    if X = 0 then
       Check((I.Key = 10) and (I.Value = 11), 'Enumerator failed at 0!')
    else if X = 1 then
       Check((I.Key = 20) and (I.Value = 21), 'Enumerator failed at 1!')
    else if X = 2 then
       Check((I.Key = 30) and (I.Value = 31), 'Enumerator failed at 2!')
    else
       Fail('Enumerator failed!');

    Inc(X);
  end;

  { Test exceptions }


  CheckException(ECollectionChangedException,
    procedure()
    var
      I : TPair<Integer, Integer>;
    begin
      for I in Dict do
      begin
        Dict.Remove(I.Key);
      end;
    end,
    'ECollectionChangedException not thrown in Enumerator!'
  );

  Check(Dict.Count = 2, 'Enumerator failed too late');

  Dict.Free();
end;

procedure TTestBidiDictionary.TestExceptions;
var
  Dict: TBidiDictionary<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();
  Dict.Add(1, '1');

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.Add(1, '2');
    end,
    'EDuplicateKeyException not thrown in Add.'
  );

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.Add(2, '1');
    end,
    'EDuplicateKeyException not thrown in Add.'
  );

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.Add(TPair<Integer, String>.Create(1, '6'));
    end,
    'EDuplicateKeyException not thrown in Add(Pair).'
  );

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.Add(TPair<Integer, String>.Create(6, '1'));
    end,
    'EDuplicateKeyException not thrown in Add(Pair).'
  );

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      Dict.ByKey[2];
    end,
    'EKeyNotFoundException not thrown in ByKey[].'
  );

  CheckException(EKeyNotFoundException,
    procedure()
    begin
      Dict.ByValue['2'];
    end,
    'EKeyNotFoundException not thrown in ByValue[].'
  );

  Dict.Add(2, '2');

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.ByKey[1] := '2';
    end,
    'EDuplicateKeyException not thrown in ByKey[] <--.'
  );

  CheckException(EDuplicateKeyException,
    procedure()
    begin
      Dict.ByValue['1'] := 2;
    end,
    'EDuplicateKeyException not thrown in ByValue[] <--.'
  );

  Dict.Free;
end;

procedure TTestBidiDictionary.TestKeys;
var
  Dict  : TBidiDictionary<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  Dict.Add(1, 'Pol');
  Dict.Add(2, 'Lol');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Kol');
  Dict.Add(5, 'Vol');

  Check((Dict.Keys.Count = Dict.Count) and (Dict.Count = 5), 'Dict.Keys.Count expected to be 5');

  Dict.Remove(5);

  Check((Dict.Keys.Count = Dict.Count) and (Dict.Count = 4), 'Dict.Keys.Count expected to be 4');

  Dict.Free;
end;

procedure TTestBidiDictionary.TestValues;
var
  Dict  : TBidiDictionary<Integer, String>;
begin
  Dict := TBidiDictionary<Integer, String>.Create();

  Dict.Add(1, 'Lol');
  Dict.Add(2, 'Pol');
  Dict.Add(3, 'Zol');
  Dict.Add(4, 'Kol');
  Dict.Add(5, 'Vol');

  Check(Dict.Values.Count = 5, 'Dict.Values.Count expected to be 4');

  Dict.Remove(1);

  Check(Dict.Values.Count = 4, 'Dict.Values.Count expected to be 4');

  Dict.Free;
end;

initialization
  TestFramework.RegisterTest(TTestBidiDictionary.Suite);

end.
