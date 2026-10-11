use bookmart;

-- A1  (b)
-- A2  (c)
-- A3  (c)
-- A4  (b)
-- A5  (b)
-- A6  (b)
-- A7  (b)
-- A8  (b)


-- B1
select * from books b
inner join authors a
on b.author_id = a.author_id;
-- (25 rows returned)

-- B2
select a.name 
from authors a
left join books b
on a.author_id = b.author_id
where b.book_id is null;
--  (0 rows returned)

-- B3
select 
a.name as author,
m.name as mentor
from authors a
join authors m
on a.mentor_id = m.author_id;
-- (3 rows returned authors (Preeti Shenoy,Alex Michaelidees,Malcom Gladwell). mentors(Chetan Bhagat,Yuval Harari,Yuval Harari)

-- B4
select name
from authors
where country = "India"
union
select a.name 
from authors a
join books b
on a.author_id = b.author_id
where b.genre = "Mythology";
-- (5 rows returned)


-- B5
select count(*)
from books
where price>(select avg(price) from books);
-- (13)


-- B6
select * from books b
where not exists(select 1 from sales s where s.book_id = b.book_id);
-- (15 rows returned)


-- B7
select
b.title,
sum(s.quantity) as total_qty
from sales s
join books b
on s.book_id = b.book_id
group by b.book_id
order by total_qty DESC
limit 1;
-- (tota quntity = 30)


-- B8
select
title,
price,
rank() over (
partition by genre
order by price desc ) AS rank_in_genre
from books
where genre = 'Business';
-- (title                  price    rank_in_genre)
-- Talking to strangers   549.00    1
-- Outliers               449.00    2
-- Blink                  399.00    3
-- Rich dad poor dad      299.00    4




-- C1
select b.title,
a.name
from books b
inner join authors a
on b.author_id = a.author_id;

-- C2
select a.name,
b.title
from authors a
left join books b
on a.author_id = b.author_id;

-- C3
select b.genre,
sum(s.quantity * b.price) as totalrevenue
from books b
inner join sales s
on b.book_id = s.book_id
group by b.genre
order by totalrevenue desc;

-- C4
select s.city,
sum(s.quantity * b.price) as totalrevenue
from sales s
inner join books b
on s.book_id = b.book_id
group by s.city
order by totalrevenue desc
limit 1;

-- C5
select b.title,
a.name as author_name
from authors a
right join books b
on a.author_id = b.author_id;

-- C6
select
a.name AS author_name,
b.title AS book_title
from authors a
left join books b
on a.author_id = b.author_id
union
select
a.name AS author_name,
b.title AS book_title
from authors a
right join books b
ON a.author_id = b.author_id;

-- C7
select
a.name AS author,
m.name AS mentor
from authors a
inner join authors m
on a.mentor_id = m.author_id;

-- C8
select
c.city,
t.customer_type
from (
    select distinct city
    from sales
) as c
cross join (
    select distinct customer_type
    from sales
) as t
order by c.city, t.customer_type;

-- C9
select name
from authors
where country = 'India'
union
select name
from authors
where born_year > 1970;

-- C10
select
b.book_id,
b.title
from books b
left join sales s
on b.book_id = s.book_id
where s.book_id is null;

-- C11
select title,
price
from books
where price > (
select avg(price)
from books
)
order by price desc;

-- C12
select *
from sales
where book_id in (
    select book_id
   from books
    where genre in ('History', 'Mythology')
);

-- C13
select title,
genre,
price
from books
where price > all (
    select price
    from books
    where genre = 'Fiction'
)
order by price desc;

-- C14
select
b.title,
b.genre,
b.price
from books b
where b.price > (
    select avg(b2.price)
   from books b2
    where b2.genre = b.genre
)
order by b.genre, b.price desc;

-- C15
select
a.author_id,
a.name
from authors a
where exists (
    select 1
    from books b
    where b.author_id = a.author_id
      and b.published_year > 2018
);

-- C16
select
a.author_id,
a.name
from authors a
where not exists (
    select 1
    from books b
    where b.author_id = a.author_id
      and b.genre = 'Business'
);

-- C17
select *
from sales
where book_id in (
    select b.book_id
    from books b
    join authors a
        on b.author_id = a.author_id
    where a.country = 'India'
);

-- C18
select
    title,
    genre,
    price,
    avg(price) over (
        partition by genre
    ) as genre_avg_price
from books;

-- C19
with ranked_books as (
    select
        title,
        genre,
        price,
        row_number() over (
            partition by genre
            order by price desc
        ) as row_num
    from books
)
select
    title,
    genre,
    price,
    row_num
from ranked_books
where row_num <= 2
order by genre, row_num;

-- C20
select
    sale_id,
    book_id,
    sale_date,
    quantity,
    lag(quantity) over (
        order by sale_date
    ) as previous_quantity
from sales
where book_id = 115
order by sale_date;

-- C21
select
    sale_id,
    sale_date,
    quantity,
    sum(quantity) over (
        order by sale_date
    ) as running_total
from sales
order by sale_date;

-- C22
with book_totals as (
    select
        book_id,
        sum(quantity) as total_qty
    from sales
    group by book_id
)
select
    b.title,
    bt.total_qty
from book_totals bt
inner join books b
    on bt.book_id = b.book_id;
    
-- C23
with genre_revenue as (
    select
        b.genre,
        sum(s.quantity * b.price) as total_revenue
    from books b
    inner join sales s
        on b.book_id = s.book_id
    group by b.genre
),
ranked_genres as (
    select
        genre,
        total_revenue,
        rank() over (
            order by total_revenue desc
        ) as revenue_rank
    from genre_revenue
)
select
    genre,
    total_revenue,
    revenue_rank
from ranked_genres
order by revenue_rank;

-- C24
with book_sales as (
    select
        b.book_id,
        b.title,
        b.genre,
        b.author_id,
        sum(s.quantity) as total_qty
    from books b
    inner join sales s
        on b.book_id = s.book_id
    group by
        b.book_id,
        b.title,
        b.genre,
        b.author_id
),
ranked_books as (
    select
        book_id,
        title,
        genre,
        author_id,
        total_qty,
        row_number() over (
            partition by genre
            order by total_qty desc, book_id
        ) as book_rank
    from book_sales
),
genre_revenue as (
    select
        b.genre,
        sum(s.quantity * b.price) as total_revenue
    from books b
    inner join sales s
        on b.book_id = s.book_id
    group by b.genre
)
select
    rb.genre,
    rb.title as top_selling_book,
    a.name as author_name,
    rb.total_qty,
    gr.total_revenue
from ranked_books rb
inner join authors a
    on rb.author_id = a.author_id
inner join genre_revenue gr
    on rb.genre = gr.genre
where rb.book_rank = 1
order by gr.total_revenue desc;
