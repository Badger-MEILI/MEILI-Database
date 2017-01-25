CREATE SCHEMA IF NOT EXISTS meili_analysis_package;

CREATE OR REPLACE FUNCTION meili_analysis_package.longest_common_subsequence(
    word1 text,
    word2 text)
  RETURNS text AS
$BODY$
declare 
aLength integer;
bLength integer;  
x text;
y text; 
xLength integer;
begin

-- hack to handle null values 
$1 = coalesce($1, '');
$2 = coalesce($2, '');

aLength = $1.length; 
bLength = $2.length; 

if ((aLength = 0) or (bLength = 0)) then return ''; 
else 
	begin  
		if (substring($1,aLength,1)=substring($2,bLength,1)) then 
			return meili_analysis_package.longest_common_subsequence(substring($1, 1,aLength-1), substring($2, 1, bLength-1)) || substring($1,aLength,1); 
		else 
			begin
				x = meili_analysis_package.longest_common_subsequence($1,substring($2, 1,bLength-1));
				xLength = char_Length(x); 
				y = meili_analysis_package.longest_common_subsequence(substring($1, 1,aLength-1),$2);
				if (char_length(x)> char_length(y)) then 
					return x; 
					else 
					return y; 
				end if;  
			end; 
		end if;
	end; 
end if; 
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
