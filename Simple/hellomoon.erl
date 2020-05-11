-module(hellomoon).

-export([run/0]).

run() ->
    show_header(),
    {Time, Fuel, Height, VelBeforeBurn, VelAfterBurn} = init(),
    show_data(Time, Fuel, Height, VelBeforeBurn, VelAfterBurn),
    do_burn(inflight, Time, Fuel, Height, VelBeforeBurn, VelAfterBurn).

do_burn(landed, Time, Fuel, Height, VelBeforeBurn, VelAfterBurn, FuelBurn) ->
    Height2 = Height + (VelBeforeBurn + VelAfterBurn)/2,
    Time2 = Time - 1,
    if 
      FuelBurn == 5 ->
        ActualTimeToContact = Height2/VelBeforeBurn;
      true ->
        ActualTimeToContact = (-VelBeforeBurn + math:sqrt(VelBeforeBurn*VelBeforeBurn + Height2*(10-2*FuelBurn))) / (5-FuelBurn)
    end,
    Vel = VelBeforeBurn + (5-FuelBurn) * ActualTimeToContact,
    io:fwrite("~n"),
    io:fwrite("Touchdown at ~7.2f seconds ~n",[Time2+ActualTimeToContact]),
    io:fwrite("Landing Velocity = ~6.2f Feet/Sec ~n",[Vel]),
    io:fwrite("~4.. B units of Fuel remaining ~n",[Fuel]),
    io:fwrite("~n"),
    AbsVel = abs(Vel),
    if 
      AbsVel =< 0.01  ->
        io:fwrite("CONGRATULATIONS! A PERFECT LANDING!!~n"),
        io:fwrite("YOUR LICENSE WILL BE RENEWED  ....  LATER.~n");
      true ->
        if 
          AbsVel =< 2 ->
    	    io:fwrite("Any Landing you can walk away from is a good landing~n");
          true ->
            io:fwrite("***** SORRY, BUT YOU BLEW IT!!!!~n"),
            io:fwrite("APPROPRIATE CONDOLENCES WILL BE SENT TO YOUR NEXT OF KIN~n")
        end
    end.

do_burn(inflight, Time, Fuel, Height, VelBeforeBurn, VelAfterBurn) ->
    if 
        Fuel =< 0 ->
            FuelBurn = 0;
        true ->
            FuelBurn = get_burn()
    end,
    {Time2, Fuel2, Height2, VelBeforeBurn2, VelAfterBurn2} = do_calc({Time, Fuel, Height, VelBeforeBurn, VelAfterBurn},FuelBurn),
    show_data(Time2, Fuel2, Height2, VelBeforeBurn2, VelAfterBurn2),
    if
        Height2>0 ->
            do_burn(inflight, Time2, Fuel2, Height2, VelBeforeBurn2, VelAfterBurn2);
        true ->
            do_burn(landed, Time2, Fuel2, Height2, VelBeforeBurn2, VelAfterBurn2, FuelBurn)
    end.

get_burn() ->
    try
      list_to_integer(string:strip(io:get_line(">"),right,$\n))
    catch
        error:Reason -> 0
    end.

show_header() ->
    io:fwrite(" YOU ARE LANDING ON THE MOON AND AND HAVE TAKEN OVER MANUAL~n"),
    io:fwrite(" CONTROL 1000 FEET ABOVE A GOOD LANDING SPOT. YOU HAVE A DOWN~n"),
    io:fwrite(" WARD VELOCITY OF 50 FEET/SEC. 150 UNITS OF FUEL REMAIN.~n"),
    io:fwrite("~n"),
    io:fwrite(" HERE ARE THE RULES THAT GOVERN YOUR APOLLO SPACE-CRAFT:~n"),
    io:fwrite(" ~n"),
    io:fwrite(" (1) AFTER EACH SECOND THE HEIGHT, VELOCITY, AND REMAINING FUEL~n"),
    io:fwrite("     WILL BE REPORTED VIA DIGBY YOUR ON-BOARD COMPUTER.~n"),
    io:fwrite(" (2) AFTER THE REPORT A '>' WILL APPEAR. ENTER THE NUMBER~n"),
    io:fwrite("     OF UNITS OF FUEL YOU WISH TO BURN DURING THE NEXT~n"),
    io:fwrite("     SECOND. EACH UNIT OF FUEL WILL SLOW YOUR DESCENT BY~n"),
    io:fwrite("     1 FOOT/SEC.~n"),
    io:fwrite(" (3) THE MAXIMUM THRUST OF YOUR ENGINE IS 30 FEET/SEC/SEC~n"),
    io:fwrite("     OR 30 UNITS OF FUEL PER SECOND.~n"),
    io:fwrite(" (4) WHEN YOU CONTACT THE LUNAR SURFACE. YOUR DESCENT ENGINE~n"),
    io:fwrite("     WILL AUTOMATICALLY SHUT DOWN AND YOU WILL BE GIVEN A~n"),
    io:fwrite("     REPORT OF YOUR LANDING SPEED AND REMAINING FUEL.~n"),
    io:fwrite(" (5) IF YOU RUN OUT OF FUEL THE '>' WILL NO LONGER APPEAR~n"),
    io:fwrite("     BUT YOUR SECOND BY SECOND REPORT WILL CONTINUE UNTIL~n"),
    io:fwrite("     YOU CONTACT THE LUNAR SURFACE.~n"),
    io:fwrite(" ~n"),
    io:fwrite(" BEGINNING LANDING PROCEDURE........~n"),
    io:fwrite(" G O O D  L U C K ! ! !~n"),
	io:fwrite("~n"),
	io:fwrite(" SEC   FEET SPEED FUEL PLOT OF DISTANCE~n").

init() ->
    Time = 0,
    Fuel = 150,
    VelBeforeBurn = 50,
    VelAfterBurn = 0,
    Height = 1000.0,
    {Time, Fuel, Height, VelBeforeBurn, VelAfterBurn}.


show_data(Time, Fuel, Height, VelBeforeBurn, VelAfterBurn) ->
    io:fwrite("~4.. B ~6.1f ~5.. B ~4.. B ~n",[Time,Height, VelBeforeBurn, Fuel]).

do_calc({Time, Fuel, Height, VelBeforeBurn, VelAfterBurn},Burn) ->
    if 
        Burn<0 -> 
            FBurn=0;
        true ->
            FBurn=Burn
    end,
    if 
        FBurn>30 -> 
            F2Burn=30;
        true ->
            F2Burn=FBurn
    end,
    if 
        F2Burn>Fuel -> 
            F3Burn=Fuel;
        true ->
            F3Burn=F2Burn
    end,
    FinalFuel = Fuel - F3Burn,
    VelAfter = VelBeforeBurn - F3Burn + 5,
    NewHeight = Height - (VelBeforeBurn + VelAfter)/2,
    NextTime = Time + 1,
    {NextTime, FinalFuel, NewHeight, VelAfter, VelAfter}.