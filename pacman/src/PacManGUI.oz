functor
import
    System
    Module
    OS
export
    StartGame
define
    [QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
    Canvas
    MainURL={OS.getCWD}
    GhostImgBlue={QTk.newImage photo(url:MainURL#"/blue.gif")}
    PacManImg={QTk.newImage photo(url:MainURL#"/pacman.gif")}
    CoinImg={QTk.newImage photo(url:MainURL#"/coin.gif")}
    WallImg={QTk.newImage photo(url:MainURL#"/bluewall.gif")}
    PelletImg={QTk.newImage photo(url:MainURL#"/pellet.gif")}
    WormHoleImg={QTk.newImage photo(url:MainURL#"/wormhole.gif")}
    WidthCell=40
    HeightCell=40
    NW=20
    NH=20
    W =WidthCell*NW
    H =HeightCell*NH
    Command
    CommandPort = {NewPort Command}
    Desc=td(canvas(bg:black
                  width:W
                  height:H
        handle:Canvas))
    Window={QTk.build Desc}
    {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
    {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
    {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
    {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}

    proc {DrawCell Elem X Y}
      case Elem of 0 then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:CoinImg)}
      [] 1 then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:WallImg)}
      [] 2 then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:PelletImg)}
      [] 3 then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:GhostImgBlue)}
      [] 4 then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:PacManImg)}
      [] 5 then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:WormHoleImg)}
      else
        {System.show 'error : something wrong with the map'}
      end
    end

    % Deprecated
    proc{DrawBox Color X Y}
      case Color of white then
        {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:PacManImg)}
        [] blueGhost then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:GhostImgBlue)}
        %[] wall then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:WallImg)} end
        %[] coin then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:CoinImg)} end
        %[] pellet then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:PelletImg)} end
        %[] wormhole then {Canvas create(image X*WidthCell+WidthCell div 2 Y*HeightCell+HeightCell div 2 image:WormHoleImg)} end
      else
        {Canvas create(rect X*WidthCell Y*HeightCell X*WidthCell+WidthCell Y*HeightCell+HeightCell fill:Color outline:black)}
      end
    end
    proc{InitLayout ListToDraw}
      proc{DrawHline X1 Y1 X2 Y2}
        if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
        skip
        else
          {Canvas create(line X1 Y1 X2 Y2 fill:black)}
          {DrawHline X1+HeightCell Y1 X2+HeightCell Y2}
        end
      end
      proc{DrawVline X1 Y1 X2 Y2}
        if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
        skip
        else
          {Canvas create(line X1 Y1 X2 Y2 fill:black)}
          {DrawVline X1 Y1+WidthCell X2 Y2+WidthCell}
        end
      end
      proc{DrawUnits L}
        case L of r(Color X Y)|T then
          {DrawBox Color X Y}
          {DrawUnits T}
        else
        skip
        end
      end
      in
        {DrawHline 0 0 0 W}
        {DrawVline 0 0 W 0}
        {DrawUnits ListToDraw}
    end
   proc{Game MySelf Ghosts Command}
      MyNewState
      NextCommand
      GhostNewStates
      GhostNewStates1
      fun {MoveTo Movement OldState}
        NewX NewY DX DY OldX OldY Color  in
        r(Color OldX OldY) = OldState
        r(DX DY) = Movement
        NewX = OldX + DX
        NewY = OldY + DY
        {DrawBox black OldX OldY}
        {DrawBox Color NewX NewY}
        r(Color NewX NewY)
      end
      fun {UserCommand Command OldState NewState}
        case Command of r(DX DY)|T then
          NewState = {MoveTo r(DX DY) OldState}
          T
        end
      end
      fun {MoveAll OldState NewState}
        Dir
        in
        case OldState of Old|T then
          Dir = {Int.'mod' {OS.rand} 4}
          case Dir of 0 then
            {MoveAll T {MoveTo r(~1 0) Old}|NewState}
          [] 1 then {MoveAll T  {MoveTo r(0 1) Old}|NewState}
          [] 2 then {MoveAll T  {MoveTo r(1 0) Old}|NewState}
          [] 3 then {MoveAll T  {MoveTo r(0 ~1) Old}|NewState}
          end
        [] nil then  NewState
        end
      end
   in
      NextCommand = {UserCommand Command MySelf MyNewState}
      GhostNewStates = {MoveAll Ghosts nil}
      GhostNewStates1 = {MoveAll GhostNewStates nil}
      {Game MyNewState GhostNewStates1 NextCommand}
   end

    proc {DrawMap R}
       proc {Helper R W Acc}
          if Acc > W then skip
          else
            {DrawRecord R.Acc Acc}
            {Helper R W Acc+1}
          end
       end
    in
       {Helper R {Width R} 1}
    end
    proc {DrawRecord R Line}
       proc {Helper R W Acc}
          if Acc > W then skip
          else
            {DrawCell R.Acc Acc Line}
            {Helper R W Acc+1}
          end
       end
    in
       {Helper R {Width R} 1}
    end
   
   proc {StartGame}
      MySelf
      Ghosts
      Map=map(r(1 1 1 1 1 1 1 5 1 1 1 1 1 1 1)
        r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
        r(1 3 0 0 0 0 0 0 0 1 2 0 0 0 1)
        r(1 0 0 0 0 0 0 0 4 1 0 0 0 0 1)
        r(1 0 0 0 0 0 0 0 0 1 1 1 0 0 1)
        r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
        r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
        r(1 1 1 0 0 1 1 1 1 1 0 0 0 0 1)
        r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
        r(1 3 0 0 0 0 0 1 4 0 0 0 0 3 1)
        r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
        r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
        r(1 0 0 0 0 0 0 1 2 0 0 0 0 0 1)
        r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
        r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
    in
      %{Browse show}
      {Window show}
      %{Browse aftershow}
      %Initialize ghosts and user
      MySelf = r(white 8 8)
      Ghosts = [r(blueGhost 1 12) r(blueGhost 11 10) r(blueGhost 4 5)]
      %{InitLayout MySelf|Ghosts}
      {DrawMap Map}
      {Game MySelf Ghosts Command}
   end
end