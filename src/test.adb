with Ada.Text_IO; use Ada.Text_IO;
procedure test is

   dim : constant integer := 100000;
   thread_num : constant integer := 2;
   
   arr : array(1..dim) of integer;
   min_index : Integer := 1;

   
   procedure Init_Arr is
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;
      arr(86) := -100;
   end Init_Arr;

   function part_sum(start_index, finish_index : in integer) return integer is
   begin
      for i in start_index..finish_index loop
            if arr(i) < arr(min_index) then
            min_index := i;
         end if;
      end loop;
      return min_index;
   end part_sum;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min_num(part_min_num : in Integer);
      entry get_min_num(part_min_num : out Integer);
   private
      tasks_count : Integer := 0;
      min1 : Integer := 0;
   end part_manager;

   protected body part_manager is
      procedure set_part_min_num(part_min_num : in Integer) is
      begin
         if arr(min1)>arr(part_min_num) then
            min1 := part_min_num;
         end if;
        tasks_count := tasks_count + 1;
      end set_part_min_num;

      entry get_min_num(part_min_num : out Integer) when tasks_count = thread_num is
      begin
         part_min_num := min1;
      end get_min_num;

   end part_manager;

   task body starter_thread is
      curr_min_num : Integer := 0;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      curr_min_num := part_sum(start_index  => start_index,
                      finish_index => finish_index);
      part_manager.set_part_min_num(curr_min_num);
   end starter_thread;

   function parallel_sum return Integer is
      min_index : integer := 0;
      thread : array(1..thread_num) of starter_thread;
   begin
      thread(1).start(1, dim / 2);
      thread(2).start(dim / 2 + 1, dim);
      part_manager.get_min_num(min_index);
      return min_index;
   end parallel_sum;

begin
   Init_Arr;
   --Put_Line(arr(part_sum(1, dim))'img);
   Put_Line(parallel_sum'img);
end test;
